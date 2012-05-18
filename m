From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Fri, 18 May 2012 13:39:29 -0400
Message-ID: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alan Cox <alan@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48527 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965949Ab2ERRkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was amusing that linux was able to make use of this 1980's
technology on machines long past its intended lifespan, but
it probably should go now -- it is causing issues in some
distros[1], and while that might be fixable, it is just not
worth it.

To set the context, the 3c501 was designed in the 1980's to be
used on 8088 PC-XT 8bit ISA machines.  It was built using
discrete TTL components and truly looks like a relic of the past.

But from a functional point of view, the real issue, as stated
in the (also obsolete) Ethernet-HowTo, is that "...the 3c501 can
only do one thing at a time -- while you are removing one packet
from the single-packet buffer it cannot receive another packet,
nor can it receive a packet while loading a transmit packet."

You know things are not good when the Kconfig help text suggests
you make a cron job doing a ping every minute.

Hardware that old and crippled is simply not going to be used by
anyone in a time where 10 year old 100Mbit PCI cards (that are
still functional) are largely give-away items.

[1] http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-card-not-detecting-934344/

Cc: Alan Cox <alan@linux.intel.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

Below is "format-patch -D" to omit full line-by-line deletions,
for review only; full patch based on net-next of today is at:

The following changes since commit 92113bfde2f0982daa5a372d67b62f3d55bbc88a:

  ipv6: bool conversions phase1 (2012-05-18 02:24:13 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git delete-3c501

for you to fetch changes up to 4a3da8d00afdf701a8ff6880180d234d8da8ab6f:

  drivers/net: delete old 8bit ISA 3c501 driver. (2012-05-18 13:10:01 -0400)

----------------------------------------------------------------
Paul Gortmaker (1):
      drivers/net: delete old 8bit ISA 3c501 driver.

 Documentation/networking/multicast.txt |    1 -
 drivers/net/Space.c                    |    3 -
 drivers/net/ethernet/3com/3c501.c      |  896 --------------------------------
 drivers/net/ethernet/3com/3c501.h      |   91 ----
 drivers/net/ethernet/3com/Kconfig      |   14 -
 drivers/net/ethernet/3com/Makefile     |    1 -
 6 files changed, 0 insertions(+), 1006 deletions(-)
 delete mode 100644 drivers/net/ethernet/3com/3c501.c
 delete mode 100644 drivers/net/ethernet/3com/3c501.h

diff --git a/Documentation/networking/multicast.txt b/Documentation/networking/multicast.txt
index b06c8c6..df1a5cf 100644
--- a/Documentation/networking/multicast.txt
+++ b/Documentation/networking/multicast.txt
@@ -15,7 +15,6 @@ IP-MRoute	AllMulti	hardware filters are of no help
 
 Board		Multicast	AllMulti	Promisc		Filter
 ------------------------------------------------------------------------
-3c501		YES		YES		YES		Software
 3c503		YES		YES		YES		Hardware
 3c505		YES		NO		YES		Hardware
 3c507		NO		NO		NO		N/A
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index e3f0fac..d108fac 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -198,9 +198,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
-#ifdef CONFIG_EL1		/* 3c501 */
-	{el1_probe, 0},
-#endif
 #ifdef CONFIG_EL16		/* 3c507 */
 	{el16_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
deleted file mode 100644
index bf73e1a..0000000
diff --git a/drivers/net/ethernet/3com/3c501.h b/drivers/net/ethernet/3com/3c501.h
deleted file mode 100644
index 183fd55..0000000
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index bad4fa6..854b8fe 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -18,20 +18,6 @@ config NET_VENDOR_3COM
 
 if NET_VENDOR_3COM
 
-config EL1
-	tristate "3c501 \"EtherLink\" support"
-	depends on ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Also, consider buying a
-	  new card, since the 3c501 is slow, broken, and obsolete: you will
-	  have problems.  Some people suggest to ping ("man ping") a nearby
-	  machine every minute ("man cron") when using this card.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c501.
-
 config EL3
 	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
 	depends on (ISA || EISA || MCA)
diff --git a/drivers/net/ethernet/3com/Makefile b/drivers/net/ethernet/3com/Makefile
index 1e5382a..74046af 100644
--- a/drivers/net/ethernet/3com/Makefile
+++ b/drivers/net/ethernet/3com/Makefile
@@ -2,7 +2,6 @@
 # Makefile for the 3Com Ethernet device drivers
 #
 
-obj-$(CONFIG_EL1) += 3c501.o
 obj-$(CONFIG_EL3) += 3c509.o
 obj-$(CONFIG_3C515) += 3c515.o
 obj-$(CONFIG_PCMCIA_3C589) += 3c589_cs.o
-- 
1.7.9.1
