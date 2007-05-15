From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 14:17:06 -0700
Message-ID: <adahcqdpz1p.fsf@cisco.com>
References: <OF0CAD6D87.DBE62968-ON872572DC.0073646A-882572DC.0073BEC2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ak@suse.de,
	krkumar2@in.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:29447 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750AbXEOVRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:17:15 -0400
In-Reply-To: <OF0CAD6D87.DBE62968-ON872572DC.0073646A-882572DC.0073BEC2@us.ibm.com> (Shirley Ma's message of "Tue, 15 May 2007 14:04:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 >       I thought to enable GSO, device driver actually does nothing rather
 > than enabling the flag. GSO moved TCP offloading to interface layer before
 > device xmit. It's a different idea with multiple packets per xmit. GSO
 > still queue the packet one bye one in QDISC and xmit one bye one. The
 > multiple packets per xmit will xmit N packets when N packets in QDISC
 > queue. Please corrent me if wrong.

Current use of GSO does segmentation just above the netdevice driver.
However there's nothing that prevents it from being used to push
segmentation into the driver -- as I described, just set NETIF_F_GSO_SOFTWARE
and do skb_gso_segment() within the driver.

As Michael Chan pointed out, tg3.c already does this to work around a
rare bug in the HW TSO implementation.  For IPoIB we could do it all
the time to get multiple send work requests from one call to the xmit
method.

 - R.
