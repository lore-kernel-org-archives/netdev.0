From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: ath9k ARM build error with v3.13-8330-g4ba9920
Date: Sun, 26 Jan 2014 10:59:48 -0500
Message-ID: <CA+5PVA4fnCo8anT0HZCVu4+AFAseibm=0yD8nL3Lm7Q5dA-qZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ath9k-devel@lists.ath9k.org, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

This commit:

commit 4dc78c437a0a2ac152a2b2c5e91a814a6ef3599e
Author: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Date:   Wed Dec 18 09:53:26 2013 +0530

    ath9k: Fix RTC reset delay

    The delay that is required after issuing a RTC reset
    varies for each chip. Handle this properly.

    Signed-off-by: Sujith Manoharan <c_manoha@qca.qualcomm.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

adds a udelay(10000) call to the ath9k driver.  This will cause a
build error on various ARM configs because the value passed to udelay
is too large:

ERROR: "__bad_udelay" [drivers/net/wireless/ath/ath9k/ath9k_hw.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2

Is the 10000 microsecond udelay really required?  I believe the limit
on ARM is 2000.  Perhaps something else could be done in this case?

josh
