From: Pavel Machek <pavel@ucw.cz>
Subject: stmmac: debugfs broken with multiple ethernets.
Date: Mon, 23 Nov 2015 16:49:17 +0100
Message-ID: <20151123154917.GA17072@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:53402 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbbKWPtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 10:49:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

stmmac_main will happily try to create two directories with the same
name.

I guess something like

static int id;
char name[100];

sprintf(name, STMMAC_RESOURCE_NAME "_%d", id++)
...

might be suitable, but did not try that further.

Best regards,

									Pavel

--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
 static int stmmac_init_fs(struct net_device *dev)
{
  -       /* Create debugfs entries */
  +       /* Create debugfs entries: FIXME: this is broken with more
  +          than one ethernet device. */
          stmmac_fs_dir = debugfs_create_dir(STMMAC_RESOURCE_NAME,
  NULL);

        if (!stmmac_fs_dir || IS_ERR(stmmac_fs_dir)) {
	
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
