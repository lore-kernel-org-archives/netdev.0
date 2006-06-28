From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: TOE, etc.
Date: Wed, 28 Jun 2006 09:25:45 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F5B3F@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jgarzik@pobox.com, swise@opengridcomputing.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:60688 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932552AbWF1Q0M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 12:26:12 -0400
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> 
> Yes, however I think the same argument could be applied to TOE.
> 
> With their RDMA NIC, we'll have TCP/SCTP connections that
> bypass netfilter, tc, IPsec, AF_PACKET/tcpdump and the rest
> of our stack while at the same time it is using the same IP
> address as us and deciding what packets we will or won't see.
> 

The whole point of the patches that opengrid has proposed is to
allow control of these issues to remain with the kernel. That is
where the ownership of the IP address logically resides, and system
administrators will expect to be able to use one set of tools to
control what is done with a given IP address.

The bypassing is already going on with iSCSI devices and with
InfiniBand devices that use IP addresses. An RDMA/IP device just
makes it harder to ignore this problem, but the problem was already
there. SDP over IB is presented to Linux users essentially as a
TOE service. Connections are made with IP and socket semantics,
and yet there is no co-ordination on routes/netfilter/etc.

I'll state right up front that I think stateful offload, when
co-ordinated with the OS, is better than stateless offload --
especially at 10G speeds.

But for plain TCP connections there are stateless offloads
available. As a product architect I am already seeking as
many ways as possible to support stateless offload as efficiently
as possible to keep that option viable for Linux users for as
high of a rate as possible. That is why we are very interested
in exploring a hardware friendly definition of vj_netchannels.

But with RDMA things are different. There is no such thing as
stateless RDMA. It is not RDMA over TCP that requires stateful
offload, it is RDMA itself. RDMA over InfiniBand is just as
much of a stateful offload as RDMA over TCP.

It is possible to build RDMA over TCP as a service that merely
uses memory mappping services in a mysterious way but is not
integrated with the network stack at all. That is essentially
how RDMA over IB is currently working.

But I believe that integrating control over the IP address,
and the associated netfilter/routing/arp/pmtu/etc issues,
is the correct path. This logic should not be duplicated,
and its control must not be split.


