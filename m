From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Subject: adding a new card to 8139too
Date: Sat, 31 Jan 2004 17:58:43 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401311738130.12810-100000@redshift.mimosa.com>
Reply-To: "D. Hugh Redelmeier" <hugh@mimosa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have a Compaq HNE-300, a 10/100 ethernet CardBus adapter.

The 8139too driver does not support this card but it is an easy matter
to make the driver do so: just add an entry to each of three tables.
I figured this out by looking at Donald Becker's driver.  I've
confirmed this by testing it on a Red Hat Linux 9 kernel.

I would like to get this adopted upstream so that I don't have to keep
building my own kernels.

I've submitted a tracker item to the official 8139too home page, but
that has gotten no attention:
	<http://sourceforge.net/tracker/index.php?func=detail&aid=829125&group_id=3242&atid=303242>

I've submitted a bug report to Red Hat, but that has gotten no
attention:
	<http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=107850>

Any suggestions on what I should do?

Although the Red Hat kernel version, the Source Forge version, and the
kernel.org 2.4.24 version of the driver claim to be DRV_VERSION
0.9.26, there are significant differences between them.  None supports
my card, as far as I can tell.

I've not tested this on a kernal.org 2.4 kernel.  It would take me a
bit of work to do so (the notebook with the card is in a different
city).

Here is the patch to 8139too.c that works for me on Red Hat Linux 9:

===================================================================
RCS file: RCS/8139too.c,v
retrieving revision 1.1
diff -u -r1.1 8139too.c
--- 8139too.c	2003/10/22 16:55:51	1.1
+++ 8139too.c	2003/10/22 16:59:37
@@ -223,6 +223,7 @@
 	RTL8129,
 	FNW3603TX,
 	FNW3800TX,
+	HNE300,
 } board_t;
 
 
@@ -244,6 +245,7 @@
 	{ "RealTek RTL8129", RTL8129_CAPS },
 	{ "Planex FNW-3603-TX 10/100 CardBus", RTL8139_CAPS },
 	{ "Planex FNW-3800-TX 10/100 CardBus", RTL8139_CAPS },
+	{ "Compaq iPaq HNE-300 CardBus (RealTek RTL8139c)", RTL8139_CAPS },
 };
 
 
@@ -260,6 +262,7 @@
 	{0x1259, 0xa117, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ALLIED8139 },
 	{0x14ea, 0xab06, PCI_ANY_ID, PCI_ANY_ID, 0, 0, FNW3603TX },
 	{0x14ea, 0xab07, PCI_ANY_ID, PCI_ANY_ID, 0, 0, FNW3800TX },
+	{0x021b, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, HNE300 },
 
 #ifdef CONFIG_8139TOO_8129
 	{0x10ec, 0x8129, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8129 },
================ end ================

Hugh Redelmeier
hugh@mimosa.com  voice: +1 416 482-8253
