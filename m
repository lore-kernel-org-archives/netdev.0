From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH 2/3] net/mlx5e: make VXLAN support conditional
Date: Thu, 5 May 2016 19:44:36 +0300
Message-ID: <CALzJLG885q-Nm4xD3FobvY4A9RhLAV3jLwfAWdJwyDOid+tJ6g@mail.gmail.com>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de> <1462365116-3856622-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matthew Finlay <matt@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Gal Pressman <galp@mellanox.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462365116-3856622-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 4, 2016 at 3:31 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> VXLAN can be disabled at compile-time or it can be a loadable
> module while mlx5 is built-in, which leads to a link error:
>
> drivers/net/built-in.o: In function `mlx5e_create_netdev':
> ntb_netdev.c:(.text+0x106de4): undefined reference to `vxlan_get_rx_port'
>
> This avoids the link error and makes the vxlan code optional,
> like the other ethernet drivers do as well.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Link: https://patchwork.ozlabs.org/patch/589296/
> Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
> ---
> I sent it originally on Feb 26 2016, but misread Saeed Mahameed's
> reply as saying that he'd fix it up himself. The new version
> should address the original comment.
> ---

Hi Arnd,

I didn't post a fix up since it is not needed anymore, see
b7aade15485a ('vxlan: break dependency with netdev drivers') in
net-next.

The new issue is introduced due to : "net/mlx5: Kconfig: Fix
MLX5_EN/VXLAN build issue" which was merged from net tree.

Dave shouldn't have merged it into net-next, I explicitly asked him
that in the cover letter.  Maybe he missed it.

I just checked and It is sufficient to only take the revert patch:
[PATCH 1/3] Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
to net-next.

Can you please confirm that with only the revert patch, you don't see
the issue ?
