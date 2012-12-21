From: Dave Jones <davej@redhat.com>
Subject: sock_ioctl sleeping while atomic warning during boot.
Date: Thu, 20 Dec 2012 21:24:09 -0500
Message-ID: <20121221022409.GA1927@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206Ab2LUCYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 21:24:12 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qBL2OBFH032130
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 21:24:11 -0500
Received: from gelk.kernelslacker.org (ovpn-113-53.phx2.redhat.com [10.3.113.53])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qBL2OAN0031798
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 21:24:11 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id qBL2O9US003485
	for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 21:24:09 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id qBL2O9VT003484
	for netdev@vger.kernel.org; Thu, 20 Dec 2012 21:24:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seen on Linus tree as of 810a4855513b9cb1a191301eb5e4e28b276cc318


 BUG: sleeping function called from invalid context at mm/slub.c:925
 in_atomic(): 1, irqs_disabled(): 0, pid: 364, name: systemd-udevd
 2 locks on stack by systemd-udevd/364:
  #0: held:     (rtnl_mutex){+.+.+.}, instance: ffffffff81d1c038, at: [<ffffffff815d82d7>] rtnl_lock+0x17/0x20
  #1: held:     (devnet_rename_seq){+.+.+.}, instance: ffffffff81d1ba60, at: [<ffffffff815c9737>] dev_change_name+0x67/0x2a0
 Pid: 364, comm: systemd-udevd Not tainted 3.7.0+ #32
 Call Trace:
  [<ffffffff810a892b>] __might_sleep+0x14b/0x210
  [<ffffffff811ce833>] __kmalloc_track_caller+0x63/0x2d0
  [<ffffffff8146810f>] ? device_rename+0x5f/0x130
  [<ffffffff8119190a>] kstrdup+0x3a/0x70
  [<ffffffff8146810f>] device_rename+0x5f/0x130
  [<ffffffff815c97d3>] dev_change_name+0x103/0x2a0
  [<ffffffff815cb851>] dev_ifsioc+0x251/0x3b0
  [<ffffffff815cbb5b>] dev_ioctl+0x1ab/0x840
  [<ffffffff81367588>] ? __const_udelay+0x28/0x30
  [<ffffffff812f7a49>] ? avc_has_perm_flags+0x29/0x2b0
  [<ffffffff815aa86d>] sock_do_ioctl+0x5d/0x70
  [<ffffffff815aa8fd>] sock_ioctl+0x7d/0x2c0
  [<ffffffff812f9d05>] ? inode_has_perm.isra.47.constprop.60+0x65/0xa0
  [<ffffffff811f1079>] do_vfs_ioctl+0x99/0x5a0
  [<ffffffff812f9dd7>] ? file_has_perm+0x97/0xb0
  [<ffffffff811f1611>] sys_ioctl+0x91/0xb0
  [<ffffffff81711480>] tracesys+0xdd/0xe2
 systemd-udevd[364]: renamed network interface eth0 to p6p1
