From: pavi1729 <pavitra1729@gmail.com>
Subject: Fwd: [PATCH stable-3.14] usb: gadget: f_ncm: fix skb_clone memleak on error
Date: Mon, 4 Jan 2016 11:46:06 +0530
Message-ID: <CAMf7+Lj-CcjD2+m9519JMgO2O0EA39qAY+FDv_4OnoshTs=Ciw@mail.gmail.com>
References: <1451813841-2359-1-git-send-email-pavitra1729@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:32822 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcADGQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 01:16:07 -0500
Received: by mail-io0-f171.google.com with SMTP id q21so145699191iod.0
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 22:16:07 -0800 (PST)
In-Reply-To: <1451813841-2359-1-git-send-email-pavitra1729@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed skb_clone pointer memleak on error path. Since the
newly cloned skb is still not added to the list, hence purge
list wont free the cloned skb.
  stable-3.14.y: 5d7b0fcc26

Signed-off-by: Pavitrakumar Managutte <pavitra1729@gmail.com>
---
 drivers/usb/gadget/f_ncm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/usb/gadget/f_ncm.c b/drivers/usb/gadget/f_ncm.c
index a9499fd..6227fa2 100644
--- a/drivers/usb/gadget/f_ncm.c
+++ b/drivers/usb/gadget/f_ncm.c
@@ -1066,6 +1066,8 @@ static int ncm_unwrap_ntb(struct gether *port,
                }

                if (!skb_pull(skb2, index)) {
+                       if(skb2 != skb)
+                               dev_kfree_skb_any(skb2);
                        ret = -EOVERFLOW;
                        goto err;
                }
--
2.1.4
