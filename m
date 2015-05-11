From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Mon, 11 May 2015 07:35:12 -0700
Message-ID: <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia>
	 <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia>
	 <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia>
	 <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net>
	 <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com>
	 <20150511133245.GA4430@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:32904 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbEKOfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 10:35:14 -0400
Received: by iepj10 with SMTP id j10so105906689iep.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 07:35:13 -0700 (PDT)
In-Reply-To: <20150511133245.GA4430@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-11 at 15:32 +0200, Pablo Neira Ayuso wrote:

> My old box is a Intel(R) Core(TM) i5-3320M CPU @ 2.60GHz
> 
> lscpu on debian shows:
> 
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              3072K
> 
> Please, carefully read my patch description. I think you can rebuild
> your work on top of this patch. Thanks.

Yes, I guess even this simple patch could make your box faster maybe.

We might have to add a noinline_for_icache_sake


# size net/core/dev.o net/core/dev.o.after
   text	   data	    bss	    dec	    hex	filename
  57028	   2260	   2864	  62152	   f2c8	net/core/dev.o
  56468	   2260	   2864	  61592	   f098	net/core/dev.o.after

diff --git a/net/core/dev.c b/net/core/dev.c
index 862875ec8f2f30dc39fec7bb6c00c75e202ebeaa..03080ed5e639a938715e6d499949fa1ab12a8908 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1765,7 +1765,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
-static inline int deliver_skb(struct sk_buff *skb,
+static noinline int deliver_skb(struct sk_buff *skb,
 			      struct packet_type *pt_prev,
 			      struct net_device *orig_dev)
 {
@@ -3545,7 +3545,7 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 	return result;
 }
 
-static inline struct sk_buff *handle_ing(struct sk_buff *skb,
+static noinline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
