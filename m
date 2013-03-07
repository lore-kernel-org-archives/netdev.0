From: Ming Lei <ming.lei@canonical.com>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Thu, 7 Mar 2013 10:03:52 +0800
Message-ID: <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
References: <51360D7C.3060209@mellanox.com>
	<CACVXFVM2MLR6HxYyvKRnqddqvRbHvzL59+_NxqFek7YN7nDhQQ@mail.gmail.com>
	<CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Liran Liss <liranl@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44603 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab3CGCDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 21:03:55 -0500
Received: from mail-ie0-f170.google.com ([209.85.223.170])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1UDQBV-0001Ax-UW
	for netdev@vger.kernel.org; Thu, 07 Mar 2013 02:03:54 +0000
Received: by mail-ie0-f170.google.com with SMTP id c11so10625633ieb.29
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 18:03:52 -0800 (PST)
In-Reply-To: <CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 7, 2013 at 4:54 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Wed, Mar 6, 2013 at 4:43 AM, Ming Lei <ming.lei@canonical.com> wrote:
>> You are adding one new PCI device inside another PCI device's probe(),
>> so the new device will be probed, since PCI probe() is scheduled by
>> work_on_cpu, then cause flush_work() called inside worker function,
>> which might be a real deadlock.
>
> So if I understand correct, you recommend to somehow avoid this nested probing?

Yes, you might need to avoid the nested probing in your driver.

>
>> I am wondering why this commit can cause the problem, since the PCI
>> device will be probed with its driver if there is one driver for it. There is no
>> any limit on when the driver should be loaded into system, either before
>> device is added or after.
>
> FWIW to undertstanding the issue - the same driver (mlx4_core) is used
> by the PF and VF, so the VF driver is already loaded at the time its
> been added as new PCI device.
>
>> From driver core view, looks no wrong things are found.
>
> So this got me confused, you pointed on possible deadlock, are you
> saying the deadlock wouldn't be the result of how the driver code is
> going nor the commited we bisected?

My commit only affects the driver loading path, but your warning
is hit in driver probe path triggered by device addition, so the lockdep
warning should still be triggered without my commit since the two paths
are totally independent, right?

Thanks,
--
Ming Lei
