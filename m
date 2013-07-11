From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 45/50] sound: usb: usx2y: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:08 +0800
Message-ID: <1373533573-12272-46-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:59832 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932590Ab3GKJMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:12:38 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: alsa-devel@alsa-project.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 sound/usb/usx2y/usbusx2yaudio.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/sound/usb/usx2y/usbusx2yaudio.c b/sound/usb/usx2y/usbusx2yaudio.c
index 4967fe9..e2ee893 100644
--- a/sound/usb/usx2y/usbusx2yaudio.c
+++ b/sound/usb/usx2y/usbusx2yaudio.c
@@ -273,7 +273,11 @@ static void usX2Y_clients_stop(struct usX2Ydev *usX2Y)
 		struct snd_usX2Y_substream *subs = usX2Y->subs[s];
 		if (subs) {
 			if (atomic_read(&subs->state) >= state_PRERUNNING) {
+				unsigned long flags;
+
+				local_irq_save(flags);
 				snd_pcm_stop(subs->pcm_substream, SNDRV_PCM_STATE_XRUN);
+				local_irq_restore(flags);
 			}
 			for (u = 0; u < NRURBS; u++) {
 				struct urb *urb = subs->urb[u];
-- 
1.7.9.5
