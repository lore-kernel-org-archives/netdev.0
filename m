From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 13:52:34 -0700
Message-ID: <adatzudq06l.fsf@cisco.com>
References: <adad517zk2r.fsf@cisco.com> <200705130800.44595.ak@suse.de>
	<adatzuerr47.fsf@cisco.com>
	<20070515.131840.52167955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, krkumar2@in.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:27192 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbXEOUxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 16:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > I'll have to think about implementing that for IPoIB.  One issue I see
 > > is if I have, say, 4 free entries in my send queue and skb_gso_segment()
 > > gives me back 5 packets to send.  It's not clear I can recover at that
 > > point -- I guess I have to check against gso_segs in the xmit routine
 > > before actually doing the segmentation.
 > 
 > I'd suggest adding a fudge factor to your free TX space, which
 > is advisable anyways so that when TX is woken up, more of
 > the transfer from queue to device can happen in a batch-like
 > fashion.

Well, IPoIB doesn't do netif_wake_queue() until half the device's TX
queue is free, so we should get batching.  However, I'm not sure that
I can count on a fudge factor ensuring that there's enough space to
handle everything skb_gso_segment() gives me -- is there any reliable
way to get an upper bound on how many segments a given gso skb will
use when it's segmented?

 - R.
