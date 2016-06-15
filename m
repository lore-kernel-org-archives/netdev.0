From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH 1/2] mlx5: only register devlink when ethernet is available
Date: Wed, 15 Jun 2016 19:04:54 +0300
Message-ID: <CALzJLG_CkvbrCehMjMht5KfMK6r-FbvPzzYUEhpA40YHymsh+Q@mail.gmail.com>
References: <20160615152816.2800830-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Eli Cohen <eli@mellanox.com>, Majd Dibbiny <majd@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615152816.2800830-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 6:27 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> We get a build error with the mlx5 driver when the ethernet
> support (CONFIG_MLX5_CORE_EN) is disabled:
>
> drivers/net/ethernet/mellanox/mlx5/core/main.c:1320:22: error: 'mlx5_devlink_eswitch_mode_set' undeclared here (not in a function)
> drivers/net/ethernet/mellanox/mlx5/core/main.c:1321:22: error: 'mlx5_devlink_eswitch_mode_get' undeclared here (not in a function)
> drivers/net/built-in.o:(.rodata+0x25a68): undefined reference to `mlx5_devlink_eswitch_mode_get'
> drivers/net/built-in.o:(.rodata+0x25a6c): undefined reference to `mlx5_devlink_eswitch_mode_set'
>
> There are actually two problems here, but they are closely related,
> so I'm addressing them both:
>
> - The header is included under an #ifdef, which is usually a bad idea
>   as it hides the function declarations, so we fail to compile even
>   if we don't actually use the functions in the end.
> - The references to the functions are kept in the object file because
>   we don't check whether they are built-in or not.
>
> As we don't want to add any useless #ifdef here, this uses an
> IS_ENABLED() check to drop the mlx5_devlink_ops structure when we don't
> need it, and to skip the register/unregister step.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f7856daf57b9 ("net/mlx5: Add devlink interface")

Hi Arnd,

We already took care of those issues, they only apply to Leon's tree
https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/,
this tree is meant to maintain MLX5 Shared code between netdev and
linux-rdma trees prior to submission to both trees.

This patch is a non-shared code and it only exists in
https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/?h=topic/net-next-mlx5.
It is yet to be submitted to Dave's net/net-next tree. later on, this
patch and all the others will go through the normal submission
process.

For the future I don't see any reason to CC the whole netdev, rdma and
kernel folks.
Unless you, Dave and Doug think otherwise.

Thanks
Saeed.
