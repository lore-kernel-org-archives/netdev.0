From: Adrian Bunk <bunk@stusta.de>
Subject: net/bluetooth/rfcomm/tty.c: use-after-free
Date: Mon, 23 Jul 2007 03:25:43 +0200
Message-ID: <20070723012543.GW26212@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bluez-devel@lists.sf.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ville Tervo <ville.tervo@nokia.com>,
	Marcel Holtmann <marcel@holtmann.org>, maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:41550 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755640AbXGWB0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 21:26:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 8de0a15483b357d0f0b821330ec84d1660cadc4e added the following 
use-after-free in net/bluetooth/rfcomm/tty.c:

<--  snip  -->

...
static int rfcomm_dev_add(struct rfcomm_dev_req *req, struct rfcomm_dlc *dlc)
{
...
        if (IS_ERR(dev->tty_dev)) {
                list_del(&dev->list);
                kfree(dev);
                return PTR_ERR(dev->tty_dev);
        }
...

<--  snip  -->

Spotted by the Coverity checker.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

