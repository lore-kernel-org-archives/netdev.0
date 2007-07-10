From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Tue, 10 Jul 2007 11:41:55 -0700
Message-ID: <20070710184155.GA6955@bougret.hpl.hp.com>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

	Hi,

	SoftMAC output the channel twice in the scan output. It should
display frequency and channel, but only once for each.
--------------------------------------------------------
          Cell 02 - Address: A2:00:04:XX:XX:XX
                    ESSID:"TheESSID"
                    Protocol:IEEE 802.11b
                    Mode:Ad-Hoc
->                  Channel:5
->                  Frequency:2.432 GHz (Channel 5)
                    Encryption key:off
                    Bit Rates:1 Mb/s; 2 Mb/s; 5.5 Mb/s; 11 Mb/s
                    Quality=95/100  Signal level=-47 dBm  Noise level=-65 dBm
                    Extra: Last beacon: 120ms ago
--------------------------------------------------------
	The fix is simple, patch attached, tested for 2.6.22 with
bcm43xx. If you like it, send it to John.
	Regards,

	Jean

Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------

--- linux/net/ieee80211/ieee80211_wx.j1.c	2007-07-10 11:28:55.000000000 -0700
+++ linux/net/ieee80211/ieee80211_wx.c	2007-07-10 11:31:18.000000000 -0700
@@ -90,14 +90,11 @@ static char *ieee80211_translate_scan(st
 	}
 
 	/* Add channel and frequency */
+	/* Note : userspace automatically computes channel using iwrange */
 	iwe.cmd = SIOCGIWFREQ;
-	iwe.u.freq.m = network->channel;
-	iwe.u.freq.e = 0;
-	iwe.u.freq.i = 0;
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
-
 	iwe.u.freq.m = ieee80211_channel_to_freq(ieee, network->channel);
 	iwe.u.freq.e = 6;
+	iwe.u.freq.i = 0;
 	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
 
 	/* Add encryption capability */
