From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 0/2] net: alternate proposal for using macvlans with forwarding acceleration
Date: Wed, 25 Sep 2013 16:16:47 -0400
Message-ID: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48725 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab3IYURI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 16:17:08 -0400
Received: from hmsreliant.think-freely.org ([2001:470:8:a08:7aac:c0ff:fec2:933b] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1VOvW9-0002Mi-2f
	for netdev@vger.kernel.org; Wed, 25 Sep 2013 16:17:05 -0400
In-Reply-To: <20130911184441.26914.10336.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John, et al. -
     As promised, heres my (very rough) first pass at an alternate propsal for
what you're trying to do with virtual station interfaces here.  Its completely
untested, but it builds, and I'll be trying to run it over the next few days
(though I'm sure I got part of the hardware manipulation wrong).  I wanted to
post it early though so you could get a look at it to see what you did and
didn't like about it.  Some notes:

1) As discussed, the major effort here is to tie in macvlans with l2 forwarding
acceleration, rather than creating a new vsi link type.  That should make
management easier for admins (be it via ovs or some other mechanism).  It
basically exposes a bit less to the user, which I think is good.

2) I've separated out the l2 forwarding acceleration operations from the
net_device_operations structure.  I'm not sure I like that yet, but I'm kind on
leaning that way.  Since a limited set of hardare supports forwarding
acceleration, it makes for a nice easy way to group functionality without
polluting the net_device_operations structure.  It also lets us group simmilar
functions together nicely (I can see a future l3_accel_ops structure if we can
do l3 flows in hardware).  Anywho, its a divergence from what we've been doing
so I thought I would call attention to it.

3) I've included a l2_accel_xmit method in the accel_ops structure for fast path
forwarding, but I'm not sure I like that.  It seems we should be able to use
ndo_start_xmit and key off some data to recognize that we should be doing
hardware forwarding.  I'm not quite sure how to do that yet though.  Something
to think about.

4) I've borrowed heavily from your vsi work of course just to get this building.
I think theres probbaly alot of consolidation that can be done in the code that
I added to ixgbe_main.c to make it smaller.  Again, I just wanted to post this
so you could speak up if you though this was all crap before I wen't too far
down the rabbit hole.

Regards
Neil
