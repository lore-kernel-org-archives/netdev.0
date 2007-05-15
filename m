From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 13:18:40 -0700 (PDT)
Message-ID: <20070515.131840.52167955.davem@davemloft.net>
References: <adad517zk2r.fsf@cisco.com>
	<200705130800.44595.ak@suse.de>
	<adatzuerr47.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, krkumar2@in.ibm.com, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754957AbXEOUSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 16:18:34 -0400
In-Reply-To: <adatzuerr47.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 15 May 2007 09:25:28 -0700

> I'll have to think about implementing that for IPoIB.  One issue I see
> is if I have, say, 4 free entries in my send queue and skb_gso_segment()
> gives me back 5 packets to send.  It's not clear I can recover at that
> point -- I guess I have to check against gso_segs in the xmit routine
> before actually doing the segmentation.

I'd suggest adding a fudge factor to your free TX space, which
is advisable anyways so that when TX is woken up, more of
the transfer from queue to device can happen in a batch-like
fashion.
