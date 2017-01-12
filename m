From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] [net] net/mlx5e: fix another -Wmaybe-uninitialized
 warning
Date: Thu, 12 Jan 2017 17:21:49 +0200
Message-ID: <46a85790-2cfe-a8d9-f764-4f736fbd1af7@mellanox.com>
References: <20170111211451.2705705-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170111211451.2705705-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/11/2017 11:14 PM, Arnd Bergmann wrote:
> As found by Olof's build bot, today's mainline kernel gained a harmless
> warning about a potential uninitalied variable reference:
>
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'parse_tc_fdb_actions':
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:769:13: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:811:21: note: 'out_dev' was declared here
>
> This was introduced through the addition of an 'IS_ERR/PTR_ERR' pair that
> gcc is unfortunately unable to completely figure out. Replacing it with
> PTR_ERR_OR_ZERO makes the code more understandable to gcc so it no longer
> warns.

can you elaborate on this a little further?

> Hadar Hen Zion already attempted to fix the warning earlier by adding
> fake initializations, but that ended up just making the code worse without
> fully addressing all warnings, so I'm reverting it now that it is no longer needed.

ok, so if your approach eliminates the warning on out_dev and also on 
the variables for which Hadar added the faked initializers, I guess we 
should be fine with this change (saw your reply on my other comment), 
just another question:

> In order to avoid pulling a variable declaration into the #ifdef, I'm
> removing it in favor of a more readable 'if()' statement here that has the same effect.

When I build here without CONFIG_INET in my system, the build goes fine 
with this approach. However, we're pretty sure that in the past we got 
0-day report from the kbuild test robot where he was unhappy that we 
make the ip_route_output_key call without being wrapped with that #if 
IS_ENABLED(CONFIG_INET) -- so, we don't want to go there again... thoughts?

Or.
