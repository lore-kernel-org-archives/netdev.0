From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH RESEND #2] ipg: Remove device claimed by dl2k from pci id
 table
Date: Mon, 08 Mar 2010 15:53:10 -0500
Message-ID: <4B9563B6.9070803@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Sorbica Shieh <sorbica@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42751 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755193Ab0CHUxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 15:53:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all -

This is a re-send of a patch I sent out nearly a month ago but didn't
get a response[2]. Re-sent without the GPG signing bit.

I've seen this report a bunch of times but google didn't point to any
resolution. I'm not really involved with network driver development, so
I'm hoping that someone who knows the history here can speak up.

I have a report[1] where the D-Link DGE-550T is being associated with the
ipg driver. It works for a very short amount of time and then fails.
Unloading the driver and loading dl2k instead results in a working
system. The DGE-550T is a DL2000 based card, but the ipg (IP1000)
driver is claiming it and has been since the driver was added to the
kernel in 2.6.24. dl2k has been claiming this ID since the 2.4 days.

Which driver is correct? Can we remove the PCI IDs associated with the
wrong driver? Users keep working around this with module blacklisting
but they shouldn't have to.

Thanks.

-Jeff

[1] https://bugzilla.novell.com/show_bug.cgi?id=579219
[2] http://marc.info/?l=linux-netdev&m=126592001219784&w=2

---

ipg: Remove device claimed by dl2k from pci id table

 This patch removes D-Link DGE-550T PCI ID (1186:4000) from the ipg
 driver. The ipg driver is for IP2000-based cards and the DGE-550T is
 a DL2000-based card. The driver loads and works for a few moments, but
 once a real workload is applied it stops operating. The ipg driver
 claimed this ID since it was introduced in 2.6.24 and it's forced many
 users to blacklist it.

 The correct driver for this hardware is the dl2k driver, which has been
 claiming this PCI ID since the 2.4 days.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 drivers/net/ipg.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -88,7 +88,6 @@ static const char *ipg_brand_name[] = {
 	"Sundance Technology ST2021 based NIC",
 	"Tamarack Microelectronics TC9020/9021 based NIC",
 	"Tamarack Microelectronics TC9020/9021 based NIC",
-	"D-Link NIC",
 	"D-Link NIC IP1000A"
 };
 @@ -97,8 +96,7 @@ static struct pci_device_id ipg_pci_tbl[
 	{ PCI_VDEVICE(SUNDANCE,	0x2021), 1 },
 	{ PCI_VDEVICE(SUNDANCE,	0x1021), 2 },
 	{ PCI_VDEVICE(DLINK,	0x9021), 3 },
-	{ PCI_VDEVICE(DLINK,	0x4000), 4 },
-	{ PCI_VDEVICE(DLINK,	0x4020), 5 },
+	{ PCI_VDEVICE(DLINK,	0x4020), 4 },
 	{ 0, }
 };

-- 
Jeff Mahoney
SUSE Labs
