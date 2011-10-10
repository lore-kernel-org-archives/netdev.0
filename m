From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame is enabled
Date: Mon, 10 Oct 2011 09:20:38 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AE77@saturn3.aculab.com>
References: <1318153939.29415.401.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Eli Cohen" <eli@mellanox.co.il>,
	<linuxppc-dev@lists.ozlabs.org>,
	"Thadeu Lima de Souza Cascardo" <cascardo@linux.vnet.ibm.com>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.co.il>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Eli Cohen" <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39396 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752759Ab1JJIVp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 04:21:45 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02979-10 for <netdev@vger.kernel.org>;
 Mon, 10 Oct 2011 09:21:43 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1318153939.29415.401.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Then, this statement:
> 
> *(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;

...
> instead do ... :

> 	*(u32 *) (&tx_desc->ctrl.vlan_tag) |=
cpu_to_be32(ring->doorbell_qpn);
> 
> (Also get rid of that cast and define vlan_tag as a __be32 to start
> with).

Agreed, casts that change the type of memory - *(foo *)&xxx - are
generally bad news unless you are casting a generic 'buffer' to
a specific structure.
I've seen far to much code that ends up being depending on the
endianness and system word size.

For the above I'd actually suggest making 'doorbell_qpn' have the
correct endianness in order to avoid the (potential) swap every
time it is set.

You also need to treble-check the required endianness for the
'vlan_tag' in the tx descriptor. What would be needed is the
MAC PCI slave were on an x86 (LE) system.

	David
