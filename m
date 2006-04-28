From: Greg KH <gregkh@suse.de>
Subject: [patch 20/24] NET: e1000: Update truesize with the length of the packet for packet split
Date: Thu, 27 Apr 2006 17:22:23 -0700
Message-ID: <20060428002223.GU18750@kroah.com>
References: <20060428001226.204293000@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Jeffrey.t.kirsher@intel.com, auke@foo-projects.org,
	davem@davemloft.net, Auke Kok <auke-jan.h.kok@intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965169AbWD1AYu@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org, jgarzik@pobox.com
Content-Disposition: inline; filename="net-e1000-update-truesize-with-the-length-of-the-packet-for-packet-split.patch"
In-Reply-To: <20060428001557.GA18750@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------

Update skb with the real packet size.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/e1000/e1000_main.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.16.11.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6.16.11/drivers/net/e1000/e1000_main.c
@@ -3851,6 +3851,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 			skb_shinfo(skb)->nr_frags++;
 			skb->len += length;
 			skb->data_len += length;
+			skb->truesize += length;
 		}
 
 		e1000_rx_checksum(adapter, staterr,

--
