From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Mon, 22 Mar 2004 00:34:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405E2673.4090808@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040321221604.GA32277@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040321221604.GA32277@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Mar 18, 2004 at 05:32:23PM +0100, Patrick McHardy wrote:
> 
>> 
>>@@ -661,6 +661,20 @@
>> 	
>> 	if ((*pskb)->dst->error)
>> 		return -1;
>>+
>>+#ifdef CONFIG_XFRM
>>+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)) {
>>+		struct xfrm_policy_afinfo *afinfo;
>>+
>>+		afinfo = xfrm_policy_get_afinfo(AF_INET);
>>+		if (afinfo != NULL) {
>>+			afinfo->decode_session(*pskb, &fl);
>>+			xfrm_policy_put_afinfo(afinfo);
>>+			if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0) != 0)
>>+				return -1;
>>+		}
>>+	}
>>+#endif
> 
> 
> BTW, you can xfrm4_route_forward here.

Is it correct that __xfrm_route_forward will use NULL for the sock
parameter to xfrm_lookup even if the packet is from a local socket ?

Regards
Patrick
