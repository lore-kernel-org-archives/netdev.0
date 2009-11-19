From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/isdn/gigaset: tasklet_init - Remove
 unnecessary leading & from second arg
Date: Thu, 19 Nov 2009 11:55:53 -0800
Message-ID: <1258660553.3863.18.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hansjoerg Lipp <hjlipp@web.de>,
	Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1054 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753532AbZKSTzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 14:55:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed function pointer use from non-majority address-of style
to majority short form without & via:

grep -rPl "\btasklet_init\s*\([^,\)]+,\s*\&" drivers/isdn | while read file ; do \
        perl -i -e 'local $/; while (<>) { s@(\btasklet_init\s*\([^,\)]+,\s*)\&@\1@g ; print ; }' $file ;\
done

Compile tested allyesconfig x86

Signed-off-by: Joe Perches <joe@perches.com>

 drivers/isdn/gigaset/bas-gigaset.c |    4 ++--
 drivers/isdn/gigaset/common.c      |    2 +-
 drivers/isdn/gigaset/interface.c   |    2 +-
 drivers/isdn/gigaset/ser-gigaset.c |    2 +-
 drivers/isdn/gigaset/usb-gigaset.c |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 9fd19db..95ebc51 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2117,7 +2117,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 		return 0;
 	}
 	tasklet_init(&ubc->sent_tasklet,
-		     &write_iso_tasklet, (unsigned long) bcs);
+		     write_iso_tasklet, (unsigned long) bcs);
 
 	spin_lock_init(&ubc->isoinlock);
 	for (i = 0; i < BAS_INURBS; ++i)
@@ -2138,7 +2138,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 	ubc->shared0s = 0;
 	ubc->stolen0s = 0;
 	tasklet_init(&ubc->rcvd_tasklet,
-		     &read_iso_tasklet, (unsigned long) bcs);
+		     read_iso_tasklet, (unsigned long) bcs);
 	return 1;
 }
 
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index c438cfc..82ed1cd 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -727,7 +727,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->ev_tail = 0;
 	cs->ev_head = 0;
 
-	tasklet_init(&cs->event_tasklet, &gigaset_handle_event,
+	tasklet_init(&cs->event_tasklet, gigaset_handle_event,
 		     (unsigned long) cs);
 	cs->commands_pending = 0;
 	cs->cur_at_seq = 0;
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 577809c..d2260b0 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -584,7 +584,7 @@ void gigaset_if_init(struct cardstate *cs)
 	if (!drv->have_tty)
 		return;
 
-	tasklet_init(&cs->if_wake_tasklet, &if_wake, (unsigned long) cs);
+	tasklet_init(&cs->if_wake_tasklet, if_wake, (unsigned long) cs);
 
 	mutex_lock(&cs->mutex);
 	cs->tty_dev = tty_register_device(drv->tty, cs->minor_index, NULL);
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index ac3409e..168d585 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -434,7 +434,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	dev_set_drvdata(&cs->hw.ser->dev.dev, cs);
 
 	tasklet_init(&cs->write_tasklet,
-		     &gigaset_modem_fill, (unsigned long) cs);
+		     gigaset_modem_fill, (unsigned long) cs);
 	return 1;
 }
 
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index f56b2a8..3ab1dae 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -614,7 +614,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	ucs->bulk_out_urb = NULL;
 	ucs->read_urb = NULL;
 	tasklet_init(&cs->write_tasklet,
-		     &gigaset_modem_fill, (unsigned long) cs);
+		     gigaset_modem_fill, (unsigned long) cs);
 
 	return 1;
 }


