From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: [PATCH]atl1e:fix bug [Bug 11454] New: atl1e - BUG: scheduling
 while atomic: modprobe/678/0x00000002
Date: Sun, 31 Aug 2008 13:31:02 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE62D7C3C@SHEXMB-01.global.atheros.com>
References: <12201583182726-git-send-email-jie.yang@atheros.com>
 <20080831050837.GK1239@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"harn-solo@gmx.de" <harn-solo@gmx.de>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.212.DSNET ([203.110.175.212]:25552 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750802AbYHaFbI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 01:31:08 -0400
In-Reply-To: <20080831050837.GK1239@parisc-linux.org>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, August 31, 2008 1:09 PM
Matthew Wilcox <matthew@wil.cx> wrote:
> How about taking my original patch, sent August 12th instead?
>  That has a good changelog and proper attribution.  The
> removal of the unnecessary casts can be a separate message.
>
> If you weren't cc'd on the patch (Jeff was), you can pick it
> up from netdev.
>
Yes, I do have the patch, should I resend with Signed-off-by: Matthew Wilcox <willy@linux.intel.com>.
for that patch may have conflicts now.

the origin patch:
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c index 82d7be1..ba22a51 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2389,9 +2389,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
        }

        /* Init GPHY as early as possible due to power saving issue  */
-       spin_lock(&adapter->mdio_lock);
        atl1e_phy_init(&adapter->hw);
-       spin_unlock(&adapter->mdio_lock);
        /* reset the controller to
         * put the device in a known good starting state */
        err = atl1e_reset_hw(&adapter->hw);

the new one:
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 7685b99..9b60352 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2390,9 +2390,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
        }

        /* Init GPHY as early as possible due to power saving issue  */
-       spin_lock(&adapter->mdio_lock);
        atl1e_phy_init(&adapter->hw);
-       spin_unlock(&adapter->mdio_lock);
        /* reset the controller to
         * put the device in a known good starting state */
        err = atl1e_reset_hw(&adapter->hw);

the line num changed from 2389 to 2390.  :(

Best wishes
jie
