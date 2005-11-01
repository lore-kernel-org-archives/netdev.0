From: Patrick McHardy <kaber@trash.net>
Subject: Re: (no subject)
Date: Tue, 01 Nov 2005 18:47:17 +0100
Message-ID: <4367AA25.6050004@trash.net>
References: <200510311111.j9VBBU7n020516@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, acme@ghostprotocols.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200510311111.j9VBBU7n020516@toshiba.co.jp>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Yasuyuki KOZAKAI wrote:
> Subject: Re: nf_conntrack comments
> From: Yasuyuki KOZAKAI <kozakai@isl.rdc.toshiba.co.jp>
> Fcc: +backup
> In-Reply-To: <20051029135524.GQ4479@sunbeam.de.gnumonks.org>
> References: <20051018084924.GD20338@sunbeam.de.gnumonks.org>
> 	<39e6f6c70510282108i60d78df6w9728f40641dccf80@mail.gmail.com>
> 	<20051029135524.GQ4479@sunbeam.de.gnumonks.org>
> X-Mailer: Mew version 4.2 on Emacs 20.7 / Mule 4.0 (HANANOEN)
> ----
> 
> Hi, Acme and all,
> 
> Acme, thank you for reviewing of nf_conntrack.
> 
> From: Harald Welte <laforge@netfilter.org>
> Date: Sat, 29 Oct 2005 15:55:24 +0200
> 
> 
>>>+       if (!h) {
>>>+               DEBUGP("icmpv6_error: no match\n");
>>>+               return NF_ACCEPT;
>>>+       } else {
>>>+               if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
>>>+                       *ctinfo += IP_CT_IS_REPLY;
>>>+       }
>>>+
>>>+       /* Update skb to refer to this connection */
>>>+       skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
>>>+       skb->nfctinfo = *ctinfo;
>>>+       return -NF_ACCEPT;
>>>+}
>>>
>>>I noticed that some of the returns are NF_ACCEPT while at leat this last one
>>>returns -NF_ACCEPT, is this a special convention or should all be negative? or
>>>positive?
>>
>>I'll check that, looks like a bug to me, too.
> 
> 
> If we don't change, the result is same. If this function return NF_ACCEPT,
> connection tracking handles packet as normal packet. But it cannot find invert
> tuple for it and stop processing after all. Then no problem.
> 
> But it may be better to replace NF_ACCEPT with -NF_ACCEPT in this function to
> stop processing early.
> 
> BTW, this is common issue in nf_conntrack and ip_conntrack. Then it is
> necessary to both of them if we want.
> 
> Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
> 
> Netfilter folks, do you have any problem if I change these return value ?

I think its a good idea, there is no point in continuing to process
these packets.
