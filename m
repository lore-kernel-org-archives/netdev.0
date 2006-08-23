From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Wed, 23 Aug 2006 14:46:38 -0400
Message-ID: <20060823184632.GA21141@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:43792 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964964AbWHWSr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 14:47:28 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit ef7d1b244fa6c94fb76d5f787b8629df64ea4046:
  Greg Kroah-Hartman:
        Merge gregkh@master.kernel.org:/.../davem/net-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Pavel Roskin:
      spectrum_cs: Fix incorrect use of pcmcia_dev_present()
      hostap: Restore antenna selection settings after port reset

 drivers/net/wireless/hostap/hostap_hw.c |    3 +++
 drivers/net/wireless/spectrum_cs.c      |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index dafaa5f..d500012 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -1042,6 +1042,9 @@ static int prism2_reset_port(struct net_
 		       dev->name, local->fragm_threshold);
 	}
 
+	/* Some firmwares lose antenna selection settings on reset */
+	(void) hostap_set_antsel(local);
+
 	return res;
 }
 
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index 7f78b78..bcc7038 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -242,7 +242,7 @@ spectrum_reset(struct pcmcia_device *lin
 	u_int save_cor;
 
 	/* Doing it if hardware is gone is guaranteed crash */
-	if (pcmcia_dev_present(link))
+	if (!pcmcia_dev_present(link))
 		return -ENODEV;
 
 	/* Save original COR value */
-- 
John W. Linville
linville@tuxdriver.com
