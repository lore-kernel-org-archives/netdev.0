From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] ftrace: change the export format of
	trace_kfree_skb()
Date: Thu, 18 Jun 2009 06:35:38 -0400
Message-ID: <20090618103538.GA8978@hmsreliant.think-freely.org>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere> <4A2F0F1D.7010101@cn.fujitsu.com> <20090610072618.GA6016@nowhere> <4A39B3E4.6060004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55887 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756314AbZFRKfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 06:35:51 -0400
Content-Disposition: inline
In-Reply-To: <4A39B3E4.6060004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2009 at 11:26:28AM +0800, Xiao Guangrong wrote:
> Use %pf instead of %p to output the function's address and print the
> protocol's name.
> 
> Before patch:
> 
>   <idle>-0     [000] 60144.542521: kfree_skb: skbaddr=de7b8240 protocol=2048 location=c1365429
>   <idle>-0     [000] 60164.488153: kfree_skb: skbaddr=da66f900 protocol=2048 location=c1365429
>   <idle>-0     [000] 60193.493933: kfree_skb: skbaddr=deaeb480 protocol=4 location=c134ec25
>   <idle>-0     [000] 60253.118421: kfree_skb: skbaddr=de7c4900 protocol=4 location=c134ec25
>           
> After patch:
> 
>   <idle>-0     [000]   169.979205: kfree_skb: skbaddr=ceddc240 protocol=ETH_P_802_2 location=netif_receive_skb
>   <idle>-0     [000]   172.587000: kfree_skb: skbaddr=ceddc300 protocol=ETH_P_802_2 location=netif_receive_skb
>     ping-3391  [000]   192.109803: kfree_skb: skbaddr=ceddc900 protocol=ETH_P_IP location=icmp_rcv
>     ping-3391  [000]   192.109902: kfree_skb: skbaddr=ceddc780 protocol=ETH_P_IP location=icmp_rcv
> 
> Changelog v1->v2:
> Convert protocol from raw numeric to its name as Frederic's suggestion
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> Acked-by: Frederic Weisbecker <fweisbec@gmail.com>
> ---
>  include/trace/events/skb.h |   70 ++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 68 insertions(+), 2 deletions(-)
> 
> diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
> index 1e8fabb..2496060 100644
> --- a/include/trace/events/skb.h
> +++ b/include/trace/events/skb.h
> @@ -7,6 +7,71 @@
>  #undef TRACE_SYSTEM
>  #define TRACE_SYSTEM skb
>  
> +#define protocol_name(protocol) { protocol, #protocol }
> +#define show_protocol_name(val)					\
> +	__print_symbolic(val,					\

Don't you need to include ftrace.h to pull in the __print_symbolic definition?
Or is that always guaranteed to be included from tracepoint.h?

Neil

> 
