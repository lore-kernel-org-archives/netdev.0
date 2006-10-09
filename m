From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 3/3] d80211: silence sparse warning: bad constant expression
Date: Mon, 9 Oct 2006 13:11:02 -0700
Message-ID: <20061009201102.GA10661@devicescape.com>
References: <20061009170159.804032000@devicescape.com> <20061009170345.GC27239@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:27591 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S964805AbWJIULM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 16:11:12 -0400
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061009170345.GC27239@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to use ARRAY_SIZE, based on comment from Joe Perches.

d80211: silence sparse warning: 'bad constant expression'

Sparse does not figure out that algs[] isn't really a variable length array.
The message is:

net/d80211/ieee80211_sta.c:934:12: error: bad constant expression

This switches algs[] to be obviously a constant array, and derives the value of
num_algs algs[].  The code is correct and equivalent with or without this
change.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sta.c
+++ wireless-dev/net/d80211/ieee80211_sta.c
@@ -930,8 +930,8 @@ static void ieee80211_rx_mgmt_auth(struc
 		printk(KERN_DEBUG "%s: AP denied authentication (auth_alg=%d "
 		       "code=%d)\n", dev->name, ifsta->auth_alg, status_code);
 		if (status_code == WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG) {
-			const int num_algs = 3;
-			u8 algs[num_algs];
+			u8 algs[3];
+			const int num_algs = ARRAY_SIZE(algs);
 			int i, pos;
 			algs[0] = algs[1] = algs[2] = 0xff;
 			if (ifsta->auth_algs & IEEE80211_AUTH_ALG_OPEN)
