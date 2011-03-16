From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38 Compile Failure e1000e Module
Date: Wed, 16 Mar 2011 16:16:57 +0100
Message-ID: <1300288617.3202.10.camel@edumazet-laptop>
References: <20110316103318.19bd03e4.frank.peters@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Frank Peters <frank.peters@comcast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62868 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab1CPPRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 11:17:04 -0400
In-Reply-To: <20110316103318.19bd03e4.frank.peters@comcast.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 mars 2011 =C3=A0 10:33 -0400, Frank Peters a =C3=A9crit =
:
> Hello,
>=20
> I cannot compile kernel 2.6.38.  Apparently, there is a build failure
> with the e1000e module (ethernet driver).  The brief error message is=
 this:
>=20
> ERROR: "crc32_le" [drivers/net/e1000e/e1000e.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
>=20
> My compiler is gcc-4.5.2 on a Gentoo x64 system.  The kernel source
> is the stock source from kernel.org.
>=20
> Please CC to frank.peters (at) comcast.net.

Hi Franck

Probably coming from commit fe46f58fa61f02
(e1000e: use either_crc_le() rather than re-write it)

Could you try following patch ?

Thanks

[PATCH] e1000e: fix kconfig for crc32 dependency

ERROR: "crc32_le" [drivers/net/e1000e/e1000e.ko] undefined!

Reported-by: Frank Peters <frank.peters@comcast.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..90d1d3c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2098,6 +2098,7 @@ config E1000
=20
 config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
+	select CRC32
 	depends on PCI && (!SPARC32 || BROKEN)
 	---help---
 	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit


