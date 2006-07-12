From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Tue, 11 Jul 2006 21:53:42 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093F9C0@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:44809 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932424AbWGLEyH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 00:54:07 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>,
	ravinandan.arakali@neterion.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller wrote:

> On receive?  There is no reason for skb->sk to be anything other than
> NULL on receive, the networking stack hasn't even seen the packet yet.
> Only the driver has seen the skb.
> 
> 

Yeah, here's roughly how LRO should work for ECN:

If CE, ECE, or CWR is set on an incoming packet, hw should stop LRO
on that TCP stream and indicate the packet(s) to the driver right
away.

In the future if RFC 3540 is implemented, hw needs to do the above
and keep track of ECT(0) and ECT(1) on incoming packets.  It needs
to do a partial sum or parity on the ECT codes and give it to the
driver when an LRO packet is ready.

There is no reason to find out if ECN is enabled or not for any
TCP connections.  Hw just needs to watch the above bits in the
incoming packets.

