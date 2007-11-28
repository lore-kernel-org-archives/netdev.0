From: Ryousei Takano <takano-ryousei@aist.go.jp>
Subject: Re: [PATCHv2 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 28 Nov 2007 16:19:05 +0900 (JST)
Message-ID: <20071128.161905.109761213.takano@axe-inc.co.jp>
References: <474B0D5D.2090506@trash.net>
	<20071127.200803.24564635.takano@axe-inc.co.jp>
	<474C0AA2.5040900@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	dada1@cosmosbay.com, t.kudoh@aist.go.jp
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:52904 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbXK1HTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 02:19:13 -0500
In-Reply-To: <474C0AA2.5040900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

> >>> +struct tc_psp_qopt
> >>> +{
> >>> +	__u32	defcls;
> >>> +	__u32	rate;
> >>> +};
> >>
> >> What unit is rate measured in?
> >>
> > 'rate' is the transmission rate in bytes per sec.
> 
> 
> So wouldn't it make sense to use u64 then for 10GBit networks?
> 
I decided to use u32 after tc_ratespec.rate is u32.
u32 is large enough for 10Gbit networks, but small for 40Gbit.
I will use u64, because code becomes simple and consistent.


> >>> +	skb_put(skb, size);
> >> This is usually done before putting data in the packet.
> >>
> > Therefore, skb_put() is needed.
> 
> 
> I meant this is usually done before writing to the packet data,
> so you should move it up a few lines.
> 
I am silly:-) I understood. Thanks.


> >>> +	while (!list_empty(&q->root))
> >>> +		psp_destroy_class(sch, list_entry(q->root.next,
> >>> +						  struct psp_class, sibling));
> >> list_for_each_entry_safe.
> >>
> > I think it works well. Should I need to use list_for_each_entry_safe?
> 
> 
> I don't doubt that it works, but list_for_each_entry_safe is
> the proper interface for this.
> 
I will fix it. Thanks.

Best regards,
Ryousei Takano
