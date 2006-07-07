From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH]NET: Add ECN support for TSO
Date: Fri, 7 Jul 2006 11:56:35 -0700
Message-ID: <000f01c6a1f7$125ebaf0$4710100a@pc.s2io.com>
References: <1151464007.5124.13.camel@rh4>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:23533 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932224AbWGGS5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 14:57:05 -0400
To: "'Michael Chan'" <mchan@broadcom.com>, <davem@davemloft.net>,
	<herbert@gondor.apana.org.au>
In-Reply-To: <1151464007.5124.13.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,
Are network cards expected to be aware-of and implement RFC3540(ECN with
nonces) ?

Thanks,
Ravi

-----Original Message-----
From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]On Behalf Of Michael Chan
Sent: Tuesday, June 27, 2006 8:07 PM
To: davem@davemloft.net; herbert@gondor.apana.org.au
Cc: netdev@vger.kernel.org
Subject: [PATCH]NET: Add ECN support for TSO


In the current TSO implementation, NETIF_F_TSO and ECN cannot be
turned on together in a TCP connection.  The problem is that most
hardware that supports TSO does not handle CWR correctly if it is set
in the TSO packet.  Correct handling requires CWR to be set in the
first packet only if it is set in the TSO header.

This patch adds the ability to turn on NETIF_F_TSO and ECN using
GSO if necessary to handle TSO packets with CWR set.  Hardware
that handles CWR correctly can turn on NETIF_F_TSO_ECN in the dev->
features flag.

All TSO packets with CWR set will have the SKB_GSO_TCPV4_ECN set.  If
the output device does not have the NETIF_F_TSO_ECN feature set, GSO
will split the packet up correctly with CWR only set in the first
segment.

It is further assumed that all hardware will handle ECE properly by
replicating the ECE flag in all segments.  If that is not the case, a
simple extension of the logic will be required.


Signed-off-by: Michael Chan <mchan@broadcom.com>



