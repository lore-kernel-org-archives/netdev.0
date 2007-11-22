From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module
Date: Thu, 22 Nov 2007 18:59:14 +0900 (JST)
Message-ID: <20071122.185914.17090750.takano@axe-inc.co.jp>
References: <20071121.191840.07671434.takano@axe-inc.co.jp>
	<474455B7.3080005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takano-ryousei@aist.go.jp, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, t.kudoh@aist.go.jp
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:49876 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbXKVJ70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 04:59:26 -0500
In-Reply-To: <474455B7.3080005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

> > +static struct sk_buff *alloc_gap_packet(struct Qdisc* sch, int size)
> > +{
> > +	struct sk_buff *skb;
> > +	struct net_device *dev = sch->dev;
> > +	unsigned char *pkt;
> > +	int pause_time = 0;
> > +	int pktsize = size + 2;
> > +
> > +	skb = alloc_skb(pktsize, GFP_ATOMIC);
> > +	if (!skb)
> > +		return NULL;
> > +
> > +	skb_reserve(skb, 2);
> 
> minor nit, but skb_reserve is not *needed* here.
> 
> skb_reserve() is used to align IP header on a 16 bytes boundary, and
> we do it on rx side to speedup IP stack, at the cost of a possibly more
> expensive DMA transfert.
> 
> Here you dont send an IP packet, do you ?
> 
Yes, I send not an IP packet but an Ethernet frame. I removed it
and confirmed to work. Thanks for your comment.

Best regards,
Ryousei Takano
