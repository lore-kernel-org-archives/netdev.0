From: Arjan van de Ven <arjan@infradead.org>
Subject: [bisected] Wireless regression in 2.6.32-git
Date: Sun, 27 Sep 2009 15:18:55 +0200
Message-ID: <20090927151855.29efcc53@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752477AbZI0NSd@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With todays git my laptop fails to associate with my access point.
Bisection points to the commit below, and reverting this one commit on
the HEAD of tree also fixes the issue, so I'm pretty confident that this
commit is to blame.

I have a 4965 wifi card in my laptop, and the network I'm trying to
connect to has no encryption. I'm running Fedora 11 as OS.

I would like to kindly request for this commit to be reverted until a
more permanent solution is found (I'm happy to test any patches)..




94f85853324e02c3a32bc3101f090dc9a3f512b4 is first bad commit
commit 94f85853324e02c3a32bc3101f090dc9a3f512b4
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Thu Sep 17 17:15:31 2009 -0700

    cfg80211: don't overwrite privacy setting
    
    When cfg80211 is instructed to connect, it always
    uses the default WEP key for the privacy setting,
    which clearly is wrong when using wpa_supplicant.
    Don't overwrite the setting, and rely on it being
    false when wpa_supplicant is not running, instead
    set it to true when we have keys.
    
    Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

:040000 040000 27fb46273e88eefee373699eb7e3f2923ac0886b
9518ee3e52c8320613cc5eee5ac54aabf082432f M	net

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
