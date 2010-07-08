From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] mac80211_hwsim: No parent is better than an illegimate one.
Date: Thu, 08 Jul 2010 09:37:43 -0700
Message-ID: <m1zky26iaw.fsf_-_@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>,
	"Greg KH <gregkh@suse.de> netdev" <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54614 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327Ab0GHQhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:37:50 -0400
In-Reply-To: <m1630q7x5v.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Thu\, 08 Jul 2010 09\:31\:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't call SET_IEEE80211_DEV.  This weakens the connections between
the phy files in sysfs slightly but otherwise it makes the driver work
in the face of tagged sysfs support.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

Johannes does this change look usable?

 drivers/net/wireless/mac80211_hwsim.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 6f8cb3e..b387222 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1282,7 +1282,6 @@ static int __init init_mac80211_hwsim(void)
 		}
 		data->dev->driver = &mac80211_hwsim_driver;
 
-		SET_IEEE80211_DEV(hw, data->dev);
 		addr[3] = i >> 8;
 		addr[4] = i;
 		memcpy(data->addresses[0].addr, addr, ETH_ALEN);
-- 
1.6.5.2.143.g8cc62

