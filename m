From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: extend extra_hdr_room to be a bytecount
Date: Thu, 19 Oct 2006 18:25:17 +0200
Message-ID: <20061019182517.2aa068e4@griffin.suse.cz>
References: <200610111158.28434.mb@bu3sch.de>
	<20061011145923.GA6785@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:38636 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1946197AbWJSQZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 12:25:19 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061011145923.GA6785@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Oct 2006 07:59:23 -0700, David Kimdon wrote:
> Perhaps rename it to extra_tx_headroom?
>  - existing users would then need to take notice of the change
>  - the name 'extra_tx_headroom' is more descriptive of what it actually is

Extend ieee80211_hw's extra_hdr_room to be a bytecount for
a device specific TX header instead of being a hardcoded
0/2 byte choice.

Based on the patch by Michael Buesch <mb@bu3sch.de>.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 drivers/net/wireless/d80211/adm8211/adm8211.c  |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt61pci.c   |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt73usb.c   |    2 +-
 include/net/d80211.h                           |    7 +++----
 net/d80211/ieee80211.c                         |    2 +-
 8 files changed, 10 insertions(+), 11 deletions(-)

--- dscape.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ dscape/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2018,7 +2018,7 @@ static int __devinit adm8211_probe(struc
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 0;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
+	hw->extra_tx_headroom = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 0;
 	hw->fraglist = 0;
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -2578,7 +2578,7 @@ static int rt2400pci_init_hw(struct rt2x
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
+	hw->extra_tx_headroom = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -2732,7 +2732,7 @@ static int rt2500pci_init_hw(struct rt2x
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
+	hw->extra_tx_headroom = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -2419,7 +2419,7 @@ static int rt2500usb_init_hw(struct rt2x
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
+	hw->extra_tx_headroom = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -3252,7 +3252,7 @@ static int rt61pci_init_hw(struct rt2x00
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
+	hw->extra_tx_headroom = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -2792,7 +2792,7 @@ static int rt73usb_init_hw(struct rt2x00
 	hw->wep_include_iv = 1;
 	hw->data_nullfunc_ack = 1;
 	hw->no_tkip_wmm_hwaccel = 1;
-	hw->extra_hdr_room = 0;
+	hw->extra_tx_headroom = 0;
 	hw->device_strips_mic = 0;
 	hw->monitor_during_oper = 1;
 	hw->fraglist = 0;
--- dscape.orig/include/net/d80211.h
+++ dscape/include/net/d80211.h
@@ -456,10 +456,6 @@ struct ieee80211_hw {
 	/* Force software encryption for TKIP packets if WMM is enabled. */
 	unsigned int no_tkip_wmm_hwaccel:1;
 
-	/* set if the payload needs to be padded at even boundaries after the
-	 * header */
-	unsigned int extra_hdr_room:1;
-
 	/* Some devices handle Michael MIC internally and do not include MIC in
 	 * the received packets passed up. device_strips_mic must be set
 	 * for such devices. The 'encryption' frame control bit is expected to
@@ -476,6 +472,9 @@ struct ieee80211_hw {
 	 * i.e. more than one skb per frame */
 	unsigned int fraglist:1;
 
+	/* Set to the size of a needed device specific skb headroom for TX skbs. */
+	unsigned int extra_tx_headroom;
+
         /* This is the time in us to change channels
          */
         int channel_change_time;
--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -1511,7 +1511,7 @@ static int ieee80211_subif_start_xmit(st
 	 * build in headroom in __dev_alloc_skb() (linux/skbuff.h) and
 	 * alloc_skb() (net/core/skbuff.c)
 	 */
-	head_need = hdrlen + encaps_len + (local->hw->extra_hdr_room ? 2 : 0);
+	head_need = hdrlen + encaps_len + local->hw->extra_tx_headroom;
 	head_need -= skb_headroom(skb);
 
 	/* We are going to modify skb data, so make a copy of it if happens to

-- 
Jiri Benc
SUSE Labs
