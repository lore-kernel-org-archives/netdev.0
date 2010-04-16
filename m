From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [net-next-2.6 PATCH 2/2] net: replace ipfragok with	skb->local_df
Date: Fri, 16 Apr 2010 10:26:09 +0800
Message-ID: <4BC7CAC1.4000803@cn.fujitsu.com>
References: <4BC70EF1.6080400@cn.fujitsu.com> <20100415151926.GA4813@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yinghai.lu@oracle.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dccp@vger.kernel.org, linux-sctp@vger.kernel.org,
	kleptog@svana.org, jchapman@katalix.com, mostrows@speakeasy.net,
	acme@xconectiva.com.br
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56360 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753516Ab0DPC1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 22:27:24 -0400
In-Reply-To: <20100415151926.GA4813@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote, at 04/15/2010 11:19 PM:
> On Thu, Apr 15, 2010 at 09:04:49PM +0800, Shan Wei wrote:
>> As Herbert Xu said: we should be able to simply replace ipfragok
>> with skb->local_df. commit f88037(sctp: Drop ipfargok in sctp_xmit function)
>> has droped ipfragok and set local_df value properly.
>>
>> The patch kills the ipfragok parameter of .queue_xmit().
> 
> Both patches look good to me.
> 
>> @@ -370,7 +370,7 @@ packet_routed:
>>  	skb_reset_network_header(skb);
>>  	iph = ip_hdr(skb);
>>  	*((__be16 *)iph) = htons((4 << 12) | (5 << 8) | (inet->tos & 0xff));
>> -	if (ip_dont_fragment(sk, &rt->u.dst) && !ipfragok)
>> +	if (ip_dont_fragment(sk, &rt->u.dst) && !skb->local_df)
>>  		iph->frag_off = htons(IP_DF);
>>  	else
>>  		iph->frag_off = 0;
> 
> This hunk looked suspecious at first.  However, it is OK because
> ever calls this with ipfragok == 1, or local_df == 1.
> 
> The first is obvious from this patch itself, the second not quite
> so obvious.
> 
> As nobody calls it with local_df == 1 anyway, and strictly speaking
> local_df shouldn't be set at all by the caller of ip_queue_xmit, we
> should simply remove the && ... bit and have 
> 
> 	if (ip_dont_fragment(sk, &rt->u.dst))

Now, PPPoX/PPPoL2TP driver still use ip_queue_xmit to send packets with ipfragok == 1.
So, now we can't remove the && ... bit. 


-- 
Best Regards
-----
Shan Wei

> 
> Cheers,


