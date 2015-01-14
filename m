From: Miquel van Smoorenburg <mikevs@xs4all.net>
Subject: net: prevent of emerging cross-namespace symlinks patches for 3.14?
Date: Wed, 14 Jan 2015 22:45:19 +0100
Message-ID: <54B6E36F.9060703@xs4all.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org,
	"Alexander Y. Fomichev" <git.user@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud2.xs4all.net ([194.109.24.21]:39322 "EHLO
	lb1-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751972AbbANVpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:45:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[first sent to lkml, now to netdev and the original patch author]

When running 'lxc' on the latest -stable kernel, 3.14.28, I'm seeing 
these errors:

Jan 14 17:47:16 lxc2 kernel: [   10.704890] WARNING: CPU: 0 PID: 3209 at 
fs/sys
fs/dir.c:52 sysfs_warn_dup+0x8c/0xb0()
Jan 14 17:47:16 lxc2 kernel: [   10.704892] sysfs: cannot create 
duplicate filename '/devices/virtual/net/eth0.104/upper_eth0'
Jan 14 17:47:16 lxc2 kernel: [   10.704954] CPU: 0 PID: 3209 Comm: 
lxc-autostart Not tainted 3.14.28-xsserver #1

I did not see these errors in 3.12. This was fixed in 3.17 by:

net: prevent of emerging cross-namespace symlinks
https://github.com/torvalds/linux/commit/4c75431ac3520631f1d9e74aa88407e6374dbbc4

net: fix creation adjacent device symlinks
https://github.com/torvalds/linux/commit/7ce64c79c4decdeb1afe0bf2f6ef834b382871d1

These patches apply cleanly to 3.14.28.

If you agree that this should go into 3.14-stable, please ack.

Thanks,

Mike.
