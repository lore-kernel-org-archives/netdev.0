From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Wed, 6 Mar 2013 22:54:49 +0200
Message-ID: <CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com>
References: <51360D7C.3060209@mellanox.com>
	<CACVXFVM2MLR6HxYyvKRnqddqvRbHvzL59+_NxqFek7YN7nDhQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Liran Liss <liranl@mellanox.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:35028 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab3CFUyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:54:50 -0500
Received: by mail-qc0-f177.google.com with SMTP id u28so1587803qcs.36
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 12:54:49 -0800 (PST)
In-Reply-To: <CACVXFVM2MLR6HxYyvKRnqddqvRbHvzL59+_NxqFek7YN7nDhQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 4:43 AM, Ming Lei <ming.lei@canonical.com> wrote:
> You are adding one new PCI device inside another PCI device's probe(),
> so the new device will be probed, since PCI probe() is scheduled by
> work_on_cpu, then cause flush_work() called inside worker function,
> which might be a real deadlock.

So if I understand correct, you recommend to somehow avoid this nested probing?

> I am wondering why this commit can cause the problem, since the PCI
> device will be probed with its driver if there is one driver for it. There is no
> any limit on when the driver should be loaded into system, either before
> device is added or after.

FWIW to undertstanding the issue - the same driver (mlx4_core) is used
by the PF and VF, so the VF driver is already loaded at the time its
been added as new PCI device.

> From driver core view, looks no wrong things are found.

So this got me confused, you pointed on possible deadlock, are you
saying the deadlock wouldn't be the result of how the driver code is
going nor the commited we bisected?

Or.
