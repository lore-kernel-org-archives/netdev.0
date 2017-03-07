From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx5e: add IPV6 dependency
Date: Tue, 07 Mar 2017 12:25:31 -0800 (PST)
Message-ID: <20170307.122531.518767642167380661.davem@davemloft.net>
References: <20170228211226.3655526-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        ogerlitz@mellanox.com, matt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170228211226.3655526-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 28 Feb 2017 22:12:04 +0100

> The ethernet support now calls directly into the ipv6 core code, which
> fails if IPV6 is a loadable module but mlx5 is built-in:
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.o: In function `mlx5e_create_encap_header_ipv6':
> en_tc.c:(.text.mlx5e_create_encap_header_ipv6+0x110): undefined reference to `ip6_route_output_flags'
> 
> This adds a dependency to ensure that MLX5_CORE_EN can only be built
> if we are able link the kernel successfully. The downside is that the
> ethernet option can be hidden. Alternatively we could make MLX5_CORE
> depend on "IPV6 || !IPV6", which would force MLX5_CORE to be a module
> when IPV6 is, including in configurations where we don't use the ethernet
> support at all.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
