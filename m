From: David Miller <davem@davemloft.net>
Subject: Re: tun offloads bug
Date: Sun, 12 Mar 2017 19:26:27 -0700 (PDT)
Message-ID: <20170312.192627.350253550836058358.davem@davemloft.net>
References: <CADS+iDW49e+oSw9p_MBOVk4Qojh+e00a5zix-sO8NQethn=pjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yaroslav.isakov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933552AbdCMC03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 22:26:29 -0400
In-Reply-To: <CADS+iDW49e+oSw9p_MBOVk4Qojh+e00a5zix-sO8NQethn=pjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Date: Wed, 8 Mar 2017 23:29:53 +0300

> Hello!
> I've found a bug in TUN/TAP driver with offloads - when Qemu is trying
> to set offloads on tap device, there is no error, but offloads are not
> appied.
> 
> The cause of this is that udev in recent systemd is using ethtool to
> disable offloads. So, udev is setting tun->dev->wanted_features via
> ethtool ioctl to disable TSO, but when qemu is trying to set offloads,
> it's using TUN/TAP ioctl which is not setting wanted_features, so
> netdev_update_features will not see features qemu wants.
> 
> This can be easily reproduced - just run qemu with
> guest_tso4=on,guest_tso6=on on systemd with systemd>=226 and after
> booting the VM, ethtool -k tap0 will show that TSO4 is disabled and
> TSO6 is enabled (systemd is not touching TSO6, that's why it's not
> affected at all)
> I've attached pretty trivial patch to fix this problem.

Please read Documentation/SubmittingPatches for the proper way to
submit a patch.

In particular you have to provide a proper signoff tag.

Thank you.
