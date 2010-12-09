From: Dave Hansen <dave@sr71.net>
Subject: brcm80211 hangs when disabling wireless
Date: Thu, 09 Dec 2010 13:26:50 -0800
Message-ID: <1291930010.7960.30.camel__47967.6688010388$1291930471$gmane$org@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Nohee Ko <noheek@b
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.sr71.net ([198.145.64.142]:52938 "EHLO blackbird.sr71.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756154Ab0LIVeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 16:34:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been getting hard hangs when I toggle the wireless on a Lenovo
S10-3.  It happens both with the physical switch and the Fn-F5 key
combo.  It's quite repeatable.  The system is quite stable when I'm not
trying to disable the wireless, though.

I've been able to get some screenshots, but the console messages don't
make it out to the disk:

	http://picasaweb.google.com/hansendc/BrcmOops#

netconsole also isn't working on this hardware.  Any other suggestions
for getting an oops out of a serial-port-challenged netbook?

It isn't completely clear to me where this bug actually is.  The stack
dump looks almost completely confined to net/mac80211/ functions, but
there are a few error printk's from brcm80211.

The first printk's are from this code, but it's apparently trying to
transmit in the mac80211 stack anyway:
        
        static int wl_ops_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
        {
                int status;
                wl_info_t *wl = hw->priv;
                WL_LOCK(wl);
                if (!wl->pub->up) {
                        WL_ERROR(("ops->tx called while down\n"));
                        status = -ENETDOWN;
                        goto done;
                }
                status = wl_start(skb, wl);
         done:
                WL_UNLOCK(wl);
                return status;
        }

I'm not completely sure that this is what is causing the hang that I'm
seeing, but it's certainly the last thing I see on the console.  

With the hardware driver in -staging, I don't expect anybody to jump out
of their seats to fix this, I just figured someone might want to see the
bug report.

-- Dave

