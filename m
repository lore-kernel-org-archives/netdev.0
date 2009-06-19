From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] ftrace: change the export format of
 trace_kfree_skb()
Date: Thu, 18 Jun 2009 20:33:31 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0906182033101.6890@gandalf.stny.rr.com>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere> <4A2F0F1D.7010101@cn.fujitsu.com> <20090610072618.GA6016@nowhere> <4A39B3E4.6060004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.124]:55435 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbZFSAd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 20:33:29 -0400
In-Reply-To: <4A39B3E4.6060004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 18 Jun 2009, Xiao Guangrong wrote:

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

I get this:

  CC      net/core/net-traces.o
In file included from include/trace/ftrace.h:262,
                 from include/trace/define_trace.h:57,
                 from include/trace/events/skb.h:107,
                 from net/core/net-traces.c:28:
include/trace/events/skb.h: In function 'ftrace_raw_output_kfree_skb':
include/trace/events/skb.h:78: error: 'ETH_P_IEEE802154' undeclared (first 
use in this function)
include/trace/events/skb.h:78: error: (Each undeclared identifier is 
reported only once
include/trace/events/skb.h:78: error: for each function it appears in.)

-- Steve
