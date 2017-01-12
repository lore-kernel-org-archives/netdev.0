From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] [net] net/mlx5e: fix another -Wmaybe-uninitialized warning
Date: Thu, 12 Jan 2017 22:55:48 +0200
Message-ID: <CAJ3xEMgr8joOeiBtDcHGXzRn7XUdNJNmGS_rWBcUqeTXJFxGVQ@mail.gmail.com>
References: <20170111211451.2705705-1-arnd@arndb.de> <46a85790-2cfe-a8d9-f764-4f736fbd1af7@mellanox.com>
 <2981112.7jTLlX72ae@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2981112.7jTLlX72ae@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2017 at 6:04 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thursday, January 12, 2017 5:21:49 PM CET Or Gerlitz wrote:


>> When I build here without CONFIG_INET in my system, the build goes fine
>> with this approach. However, we're pretty sure that in the past we got
>> 0-day report from the kbuild test robot where he was unhappy that we
>> make the ip_route_output_key call without being wrapped with that #if
>> IS_ENABLED(CONFIG_INET) -- so, we don't want to go there again... thoughts?

> I went back and forth between the two versions, either leaving the #if
> in place, or using the if(IS_ENABLED()) check to be really sure that
> we can't get compile error here.

> I did check that ip_route_output_key() is always declared, but now
> I see that net/route.h might not always be included from en_tc.c
> if CONFIG_INET is disabled (I don't see how it gets included, but
> it obviously is when CONFIG_INET is turned on).

> Adding an explicit include of that file should probably avoid the
> case you ran into earlier, but for I agree it's safer to not rely
> on that here for a bugfix, and just leave the #ifdef. Do you want to
> modify it yourself, or should I spin a new version with that?

I can do that next week, thanks
