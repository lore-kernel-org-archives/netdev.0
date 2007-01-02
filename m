From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211: Reinit keys on mode change
Date: Tue, 2 Jan 2007 16:31:22 +0100
Message-ID: <a32f33a40701020731j4943c268qf5371ee2243f4d27@mail.gmail.com>
References: <45996CE9.1010903@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:51633 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbXABPbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 10:31:24 -0500
Received: by wr-out-0506.google.com with SMTP id 68so464127wri
        for <netdev@vger.kernel.org>; Tue, 02 Jan 2007 07:31:23 -0800 (PST)
To: "Jan Kiszka" <jan.kiszka@web.de>
In-Reply-To: <45996CE9.1010903@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/1/07, Jan Kiszka <jan.kiszka@web.de> wrote:
> Switching the interface mode with some encryption keys set and then later
> touching any key, triggers an oops because ieee80211_if_reinit fails to
> NULL'ify the related pointers after free'ing the key on mode change. Long
> explanation, simple fix below.
>
> Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
>
> [Sorry, yet another rt2x00 CVS patch...]

To make it easier for everybody, here is the same patch
only this time applied to the dscape git tree. ;)

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3e9d531..7d4ec56 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -229,6 +229,7 @@ void ieee80211_if_reinit(struct net_device *dev)
 					   local->keys[i], 0);
 #endif
 		ieee80211_key_free(sdata->keys[i]);
+		sdata->keys[i] = NULL;
 	}

 	/* Shouldn't be necessary but won't hurt */
