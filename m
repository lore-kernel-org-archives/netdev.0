From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 09:25:28 -0700
Message-ID: <adatzuerr47.fsf@cisco.com>
References: <p73wszfenni.fsf@bingen.suse.de>
	<20070511093714.GR2012@bingen.suse.de> <adad517zk2r.fsf@cisco.com>
	<200705130800.44595.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:26315 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756672AbXEOQZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 12:25:39 -0400
In-Reply-To: <200705130800.44595.ak@suse.de> (Andi Kleen's message of "Sun, 13 May 2007 08:00:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > As I said before, getting multiple packets in one call to xmit would
 > > be nice for amortizing per-xmit overhead in IPoIB.  So it would be
 > > nice if the cases where the stack does GSO ended up passing all the
 > > segments into the driver in one go.
 > 
 > Well TCP does upto 64k -- that is what GSO is about.

I see... the plan would be to add NETIF_F_GSO_SOFTWARE to the device
features and use skb_gso_segment() in the netdevice driver?  (I just
studied GSO more carefully -- I hadn't realized that was possible)

I'll have to think about implementing that for IPoIB.  One issue I see
is if I have, say, 4 free entries in my send queue and skb_gso_segment()
gives me back 5 packets to send.  It's not clear I can recover at that
point -- I guess I have to check against gso_segs in the xmit routine
before actually doing the segmentation.

 - R.
