From: David Miller <davem@davemloft.net>
Subject: Re: ppp/l2tp doing oversized allocations ?
Date: Sat, 19 May 2012 00:46:52 -0400 (EDT)
Message-ID: <20120519.004652.2261671316587735315.davem@davemloft.net>
References: <20120514162923.GA4439@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fedoraproject.org,
	edumazet@google.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab2ESEq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 00:46:56 -0400
In-Reply-To: <20120514162923.GA4439@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 14 May 2012 12:29:23 -0400

> We just got this trace from reported by a Fedora user running 3.3.4
> 
> :WARNING: at mm/page_alloc.c:2204 __alloc_pages_nodemask+0x231/0x8f0()
> :Call Trace:
> : [<ffffffff81057abf>] warn_slowpath_common+0x7f/0xc0
> : [<ffffffff81057b1a>] warn_slowpath_null+0x1a/0x20
> : [<ffffffff81129671>] __alloc_pages_nodemask+0x231/0x8f0
> : [<ffffffff814e84db>] ? dev_queue_xmit+0x1db/0x640
> : [<ffffffff8151f210>] ? ip_forward_options+0x1f0/0x1f0
> : [<ffffffff814ef7a1>] ? neigh_direct_output+0x11/0x20
> : [<ffffffff81520dee>] ? ip_finish_output+0x17e/0x2f0
> : [<ffffffff8151f210>] ? ip_forward_options+0x1f0/0x1f0
> : [<ffffffff811608d3>] alloc_pages_current+0xa3/0x110
> : [<ffffffff811254b4>] __get_free_pages+0x14/0x50
> : [<ffffffff8116b99f>] kmalloc_order_trace+0x3f/0xd0
> : [<ffffffff8156d137>] ? xfrm4_output_finish+0x27/0x40
> : [<ffffffff8116c8c7>] __kmalloc+0x177/0x1a0
> : [<ffffffff81521196>] ? ip_queue_xmit+0x156/0x400
> : [<ffffffff814dab07>] pskb_expand_head+0x87/0x310
> : [<ffffffff8113dbf9>] ? __mod_zone_page_state+0x49/0x50
> : [<ffffffffa05e84dd>] pppol2tp_xmit+0x1ed/0x220 [l2tp_ppp]

So it's ESP encapsulated IPSEC over L2tp.

Eric, I wonder if session->hdr_len can take on undesirable values and
thus trip up the skb COW'ing calculations you added?
