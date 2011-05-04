From: Seth Forshee <seth.forshee@canonical.com>
Subject: ath5k regression associating with APs in 2.6.38
Date: Wed, 4 May 2011 10:38:19 -0500
Message-ID: <20110504153819.GA4551@thinkpad-t410>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been investigating some reports of a regression in associating with
APs with AR2413 in 2.6.38. Association repeatedly fails with some
"direct probe to x timed out" messages (see syslog excerpt below),
although it will generally associate eventually, after many tries.

Bisection identifies 8aec7af (ath5k: Support synth-only channel change
for AR2413/AR5413) as offending commit. Prior to this commit there are
no direct probe messages at all in the logs. I've also found that
forcing fast to false at the top of ath5k_hw_reset() fixes the issue.
I'm not sure what the connection is between this commit and the
timeouts. Any suggestions?

Thanks,
Seth


May  4 09:32:15 AcerAspire5100 wpa_supplicant[757]: Trying to associate with c0:3f:0e:b9:f3:b2 (SSID='aureola' freq=2452 MHz)
May  4 09:32:15 AcerAspire5100 kernel: [  120.063271] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
May  4 09:32:16 AcerAspire5100 kernel: [  120.260074] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
May  4 09:32:16 AcerAspire5100 kernel: [  120.460084] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
May  4 09:32:16 AcerAspire5100 kernel: [  120.660082] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
May  4 09:32:25 AcerAspire5100 wpa_supplicant[757]: Authentication with c0:3f:0e:b9:f3:b2 timed out.
