From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5e throwing RTNL_ASSERT error on vxlan_get_rx_port
Date: Fri, 22 Apr 2016 23:02:05 +0300
Message-ID: <CALzJLG9JG19GhqWoMZonwxaubUeiw-wvZfKXCv6uxYEq3GLRNA@mail.gmail.com>
References: <CAKgT0Ud2yc3ZgMpSwdWAvaJ6b2-Q5QO=SEOb709y1BHepU_rQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Matthew Finlay <matt@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:36167 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbcDVUCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 16:02:25 -0400
Received: by mail-yw0-f171.google.com with SMTP id o66so133830430ywc.3
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 13:02:24 -0700 (PDT)
In-Reply-To: <CAKgT0Ud2yc3ZgMpSwdWAvaJ6b2-Q5QO=SEOb709y1BHepU_rQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 10:30 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> From what I can tell it looks like the recent commit that changed the
> behavior for vxlan_get_rx_port has broken the mlx5 driver as it was
> calling vxlan_get_rx_port in mlx5e_create_netdev which didn't hold the
> rtnl lock.  As a result it is throwing RTNL_ASSERT errors.
>

Nice catch Alex.

> I'm not sure if anyone has already seen this or not but I thought I
> would bring it to your attention.  Odds are this probably something
> that needs to be fixed in the mlx5e driver and if I have time I might
> get to it sometime in the next several days if nobody else ends up
> addressing it.
>

Matt will handle it, he is already preparing two fixes in mlx5 vxlan
area, one is to address the kconfig issue Arnd reported and the other
is to address the scheduling while atomic in mlx5e_vxlan_add ndo
implementation which can sleep, from vxlan module it is called under
rcu_read_lock.

Thanks,
Saeed
