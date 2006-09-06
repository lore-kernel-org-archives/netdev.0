From: Greg KH <gregkh@suse.de>
Subject: [patch 33/37] sky2: clear status IRQ after empty
Date: Wed, 6 Sep 2006 15:57:55 -0700
Message-ID: <20060906225755.GH15922@kroah.com>
References: <20060906224631.999046890@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964971AbWIFXKN@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename="sky2-status-clr.patch"
In-Reply-To: <20060906225444.GA15922@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@osdl.org>

Don't clear status IRQ until list has been read to avoid causing
status list wraparound. Clearing IRQ forces a Transmit Status update
if it is pending.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.17.11.orig/drivers/net/sky2.c
+++ linux-2.6.17.11/drivers/net/sky2.c
@@ -2016,6 +2016,9 @@ static int sky2_status_intr(struct sky2_
 		}
 	}
 
+	/* Fully processed status ring so clear irq */
+	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+
 exit_loop:
 	return work_done;
 }
@@ -2218,9 +2221,6 @@ static int sky2_poll(struct net_device *
 	*budget -= work_done;
 	dev0->quota -= work_done;
 
-	if (status & Y2_IS_STAT_BMU)
-		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-
 	if (sky2_more_work(hw))
 		return 1;
 

--
