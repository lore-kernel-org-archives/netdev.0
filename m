From: Seth Forshee <seth.forshee@canonical.com>
Subject: Performance regression with virtio_net
Date: Thu, 27 Jul 2017 12:09:42 -0500
Message-ID: <20170727170942.ub24lwgrl3x2outp@ubuntu-hedt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:33508 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751122AbdG0RJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 13:09:44 -0400
Received: by mail-it0-f44.google.com with SMTP id v127so2520717itd.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 10:09:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing a performance regression with virtio_net that looks to have
started in 4.12-rc1. I only see it in one context though, downloading
snap packages from the Ubuntu snap store. For example:

 https://api.snapcraft.io/api/v1/snaps/download/b8X2psL1ryVrPt5WEmpYiqfr5emixTd7_1797.snap

which redirects to Internap's CDN. Normally this downloads in a few
seconds at ~10 MB/s, but with 4.12 and 4.13 it takes minutes with a rate
of ~150 KB/s. Everything else I've tried downloads as normal speeds.

I bisected this to 680557cf79f8 "virtio_net: rework mergeable buffer
handling". If I revert this on top of 4.13-rc2 (along with other changes
needed to successfully revert it) speeds return to normal.

Thanks,
Seth
