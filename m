From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [BUG ?] brcmsmac: condition with no effect
Date: Wed,  8 Jul 2015 15:17:40 +0200
Message-ID: <1436361460-30554-1-git-send-email-hofrat@osadl.org>
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Joe Perches <joe@perches.com>, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>                                      

scanning for trivial bug-patters with coccinelle spatches returned:
drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c:3391
        WARNING: condition with no effect (if branch == else)

added in 'commit 5b435de0d786 ("net: wireless: add brcm80211 drivers")'

drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c:wlc_lcnphy_deaf_mode()
(line numbers are from linux-next v4.2-rc2)
3391         if (LCNREV_LT(pi->pubpi.phy_rev, 2)) {
3392                 mod_phy_reg(pi, 0x4b0, (0x1 << 5), (mode) << 5);                                       
3393                 mod_phy_reg(pi, 0x4b1, (0x1 << 9), 0 << 9);
3394         } else {
3395                 mod_phy_reg(pi, 0x4b0, (0x1 << 5), (mode) << 5);
3396                 mod_phy_reg(pi, 0x4b1, (0x1 << 9), 0 << 9);
3397         }

Can't figure out what the intent of this condition is but it currently has
no effect as if == else and this most likely is not the intent.
