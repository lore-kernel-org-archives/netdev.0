From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/3] wext: fix an ancient bug
Date: Wed, 14 Jun 2017 13:55:20 +0200
Message-ID: <20170614115523.16379-1-johannes@sipsolutions.net>
Cc: Robert O'Callahan <robert@ocallahan.org>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37320 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752260AbdFNLzn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:55:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert O'Callahan reported that since struct iwreq is smaller than
struct ifreq, if it happens to land at the end of a mapped section
userspace will erroneously get -EFAULT.

Bug report is https://bugzilla.kernel.org/show_bug.cgi?id=195869.

This bug is ancient, it kernel 2.1.15 was the first to contain the
bug, and was released almost exactly 20.5 years ago.

Dave, I don't know if we should even bother sending this to stable,
but if so, the third patch will apply by itself but not compile, a
smaller patch consist of only the net/core/dev_ioctl.c modifications
with a cast thrown in where the compile fails/warns due to passing
the wrong struct type.

Should I merge this through my tree?

johannes
