From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: mlx5e throwing RTNL_ASSERT error on vxlan_get_rx_port
Date: Mon, 25 Apr 2016 11:07:12 +0200
Message-ID: <0088d4e8-5303-4714-f46b-b783534725f5@redhat.com>
References: <CAKgT0Ud2yc3ZgMpSwdWAvaJ6b2-Q5QO=SEOb709y1BHepU_rQw@mail.gmail.com>
 <CALzJLG9JG19GhqWoMZonwxaubUeiw-wvZfKXCv6uxYEq3GLRNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Matthew Finlay <matt@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086AbcDYJHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 05:07:16 -0400
In-Reply-To: <CALzJLG9JG19GhqWoMZonwxaubUeiw-wvZfKXCv6uxYEq3GLRNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 22.04.2016 22:02, Saeed Mahameed wrote:
> On Fri, Apr 22, 2016 at 10:30 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> From what I can tell it looks like the recent commit that changed the
>> behavior for vxlan_get_rx_port has broken the mlx5 driver as it was
>> calling vxlan_get_rx_port in mlx5e_create_netdev which didn't hold the
>> rtnl lock.  As a result it is throwing RTNL_ASSERT errors.
>>
> 
> Nice catch Alex.
> 
>> I'm not sure if anyone has already seen this or not but I thought I
>> would bring it to your attention.  Odds are this probably something
>> that needs to be fixed in the mlx5e driver and if I have time I might
>> get to it sometime in the next several days if nobody else ends up
>> addressing it.
>>
> 
> Matt will handle it, he is already preparing two fixes in mlx5 vxlan
> area, one is to address the kconfig issue Arnd reported and the other
> is to address the scheduling while atomic in mlx5e_vxlan_add ndo
> implementation which can sleep, from vxlan module it is called under
> rcu_read_lock.

Hm, I probably overlooked something during review or this change in
vxlan_get_rx_port or something came in during the time I was pushing
those changes at the same time. I just had a look and the fix shouldn't
be that hard.

Thanks,
Hannes
