From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Kernel 2.6.37-git10 build failure: cassini.c
Date: Fri, 14 Jan 2011 10:09:43 +0200
Message-ID: <AANLkTin61iqrD0Jbax+cvQ1wxD8b=c4KJv7pBSvU7kbv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>,
	Christoph Egger <siccegge@cs.fau.de>,
	Jiri Pirko <jpirko@redhat.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43082 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab1ANIJq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 03:09:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/cassini.c: In function =91cas_get_vpd_info=92:
drivers/net/cassini.c:3358: error: implicit declaration of function
=91of_get_property=92
drivers/net/cassini.c:3358: warning: assignment makes pointer from
integer without a cast
drivers/net/cassini.c: In function =91cas_init_one=92:
drivers/net/cassini.c:5035: error: implicit declaration of function
=91pci_device_to_OF_node=92
drivers/net/cassini.c:5035: warning: assignment makes pointer from
integer without a cast
make[3]: *** [drivers/net/cassini.o] Error 1
make[2]: *** [drivers/net] Error 2


The first part can be solved with:

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7206ab2..fe3795e 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -94,6 +94,7 @@
 #include <linux/tcp.h>
 #include <linux/mutex.h>
 #include <linux/firmware.h>
+#include <linux/of.h>

 #include <net/checksum.h>
