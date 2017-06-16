From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-06-16
Date: Fri, 16 Jun 2017 09:19:35 +0200
Message-ID: <20170616071936.4515-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57830 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752742AbdFPHTm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 03:19:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here I just have the cleanups with the fix for that ancient bug
I sent the RFC patches for.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit c5549ee40112f2511a794c9aad7eb6ac5f18b0eb:

  Merge tag 'mac80211-for-davem-2017-06-13' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2017-06-13 13:34:13 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-06-16

for you to fetch changes up to 68dd02d19c811ca8ea60220a9d73e13b4bdad73a:

  dev_ioctl: copy only the smaller struct iwreq for wext (2017-06-14 13:52:44 +0200)

----------------------------------------------------------------
Here's just the fix for that ancient bug:
 * remove wext calling ndo_do_ioctl, since nobody needs
   that now and it makes the type change easier
 * use struct iwreq instead of struct ifreq almost everywhere
   in wireless extensions code
 * copy only struct iwreq from userspace in dev_ioctl for the
   wireless extensions, since it's smaller than struct ifreq

----------------------------------------------------------------
Johannes Berg (3):
      wireless: wext: remove ndo_do_ioctl fallback
      wireless: wext: use struct iwreq earlier in the call chain
      dev_ioctl: copy only the smaller struct iwreq for wext

 include/net/wext.h       |  4 ++--
 net/core/dev_ioctl.c     | 19 ++++++++++++++++---
 net/wireless/wext-core.c | 22 +++++++++-------------
 3 files changed, 27 insertions(+), 18 deletions(-)
