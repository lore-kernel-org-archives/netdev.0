From: Brandon Philips <brandon@ifup.org>
Subject: dmfe/tulip device id overlap
Date: Tue, 24 Nov 2009 20:36:03 -0800
Message-ID: <20091125043603.GK14043@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Ringstrom <tori@unhappy.mine.nu>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:58982 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932739AbZKYEgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 23:36:01 -0500
Received: by pzk1 with SMTP id 1so5325921pzk.33
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 20:36:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All-

dmfe and tulip have an overlap of device IDs and it has been discussed
before without resolution[1][2].

The device ID in particular is:

	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },

Users of Fedora[3] and openSUSE[4] are feeling pain from this but
Ubuntu users are avoiding the issue do to the patch below.

This patch comes almost directly from the discussion on the
linux-sparc thread[2]. So, can we merge that patch? Or can one of the
maintainers come up with a less hacky solution (e.g. fix tulip)?

Cheers,

	Brandon

[1] http://www.mail-archive.com/debian-sparc@lists.debian.org/msg21647.html
[2] http://marc.info/?l=linux-sparc&m=123698905214250&w=2
[3] https://bugzilla.redhat.com/show_bug.cgi?id=277731
[4] https://bugzilla.novell.com/show_bug.cgi?id=537016

From: Ben Collins <bcollins@ubuntu.com>
Date: Wed, 18 Jul 2007 17:48:25 +0000 (-0400)
Subject: UBUNTU: SAUCE: tulip: Let dmfe handle davicom on non-sparc
X-Git-Tag: Ubuntu-2.6.31-10.31~680
X-Git-Url: http://kernel.ubuntu.com/git?p=ubuntu%2Fubuntu-karmic.git;a=commitdiff_plain;h=886595ab493b5c5fcf23b55b3ebf46bfe219a5d0

UBUNTU: SAUCE: tulip: Let dmfe handle davicom on non-sparc

Signed-off-by: Ben Collins <ben.collins@canonical.com>
---

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 4cf9a65..b75f65c 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -228,8 +228,12 @@ static struct pci_device_id tulip_pci_tbl[] = {
 	{ 0x1259, 0xa120, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
 	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
+	/* Ubuntu: On non-sparc, this seems to be handled better by the
+	 * dmfe driver. */
+#ifdef __sparc__
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
+#endif
 	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
 	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
