From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 00/14] [RFC] Phonet protocol stack
Date: Fri, 19 Sep 2008 10:25:17 +0300
Message-ID: <200809191025.17790.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221624949.23335.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Dan Williams" <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:34803 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbYISH0T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 03:26:19 -0400
In-Reply-To: <1221624949.23335.11.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wednesday 17 September 2008 07:15:48 ext Dan Williams, you wrote:
> Do you have any documentation or examples of how userspace uses this
> interface?

On top of this patchset, a modem-to-Linux congestion control protocol, =
and of=20
course, a netif would be needed:

 +--------------+=20
 | TCP/IP stack |
 +--------------+
 |  GPRS netif  | (point-to-point IP network interface)
 +--------------+
 | Phonet pipe  | (PF_PHONET, SOCK_SEQPACKET)
 +--------------+
 | Phonet stack | <--- this patchset
 +--------------+=20
 |  HW driver   | <--- sent to linux-omap
 +--------------+

I still need to polish the Phonet pipe and GPRS netif code.

This is somewhat similar to the UDP-encapsulation already in the kernel=
 (L2TP,=20
IPsec). In userland, that would look something like:

 int lfd, fd, val =3D PNPIPE_ENCAP_IP, ifindex;
 lfd =3D socket(PF_PHONET, SOCK_SEQPACKET, 0);
 listen(lfd, 1);
 /* Wait for modem */
 fd =3D accept(lfd, NULL, NULL);
 setsockopt(fd, SOL_PNPIPE, PNPIPE_ENCAP, &val, sizeof(val));
 getsockopt(fd, SOL_PNPIPE, PNPIPE_IFINDEX, &ifindex, sizeof(ifindex));
 printf("Created GPRS interface %s\n", if_indextoname(ifindex, buf));
 /* Configure and use IP interface */
 close(fd);
 printf("Destroyed GPRS interface\n");

I am all for using a more generic and/or cleaner userland API if there =
is a=20
better alternative.

> I'm starting to see a proliferation of methods by which=20
> userspace now has to talk to cellular modems and I'd like to keep a
> handle on them, despite the fact that they all pretty much do the sam=
e
> thing and thus you'd think they'd expose about the same interface...

Regards,

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
