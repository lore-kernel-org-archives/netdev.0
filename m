From: Michael Buesch <mb@bu3sch.de>
Subject: mac80211: NOHZ: local_softirq_pending 08
Date: Fri, 11 Sep 2009 16:48:49 +0200
Message-ID: <200909111648.50902.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kalle.Valo@iki.fi,
	Johannes Berg <johannes@sipsolutions.net>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:34617 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbZIKOst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 10:48:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

mac80211 (or some other part of the networking stack) triggers this warning
in the NOHZ code:
NOHZ: local_softirq_pending 08

08 seems to be NET_RX_SOFTIRQ.

It happens, because my test driver b43 handles all RX and TX-status callbacks in
process context. I guess some part of the networking stack expects RX to be in
tasklet and/or softirq context.

We also have a report of this warning in wl1251, so it's probably not a b43 problem.

-- 
Greetings, Michael.
