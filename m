From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/8] d80211/bcm43xx: Add wireless statistics.
Date: Tue, 08 Aug 2006 18:58:30 -0500
Message-ID: <44D92526.8010206@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:35325 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030344AbWHHX6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:58:33 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of 8 patches implement wireless statistics for bcm43xx using
the d80211 stack.They also set the framework for the implementation in
other drivers that use the d80211 code. The specific parts are as follows:

1. Add new variables to struct ieee80211_rx_status to contain the
latest values for signal, noise, and the maximum value of the received
ssi. These could be u8's, but I left them as integers in case other
drivers needed larger values.

2. Add new variables to struct ieee80211_local to contain the
link_quality and noise.Again these could be u8's for bcm43xx.

3. Add last_signal, last_noise and max_rssi to struct sta_info.

4. Remove link_quality and add link_noise to struct bcm43xx_stats.

5. Remove the bogus calculation of link_quality and save the value of
link_noise in the new variable bcm->stats.link_noise.

6. In bcm43xx_xmit.c, store the new variables in status for
transmission to ieee80211.

7. In ieee80211_rx_h_sta_process, transfer the new status variables
into struct sta_info.

8. Add the appropriate range parameters and routine
ieee80211_get_wireless_stats to ieee80211_ioctl.c.

Signed-Off-By: Larry Finger <Larry.Finger.lwfinger.net>



