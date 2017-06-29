From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] [net-next] net/mlx5e: select CONFIG_MLXFW
Date: Thu, 29 Jun 2017 06:47:16 +0300
Message-ID: <CAJ3xEMj3GdWbUGm8DrMhoc282FoGE9f7XxZB8tauz1J_gdK-_A@mail.gmail.com>
References: <20170628201032.3178691-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33418 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdF2DrR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 23:47:17 -0400
In-Reply-To: <20170628201032.3178691-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:10 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> With the introduction of mlx5 firmware flash support, we get a link
> error with CONFIG_MLXFW=m and CONFIG_MLX5_CORE=y:
>
> drivers/net/ethernet/mellanox/mlx5/core/fw.o: In function `mlx5_firmware_flash':
> fw.c:(.text+0x9d4): undefined reference to `mlxfw_firmware_flash'

Thanks Arnd, I got a report on that from Jakub but you were before me here..

> We could have a more elaborate method to force MLX5 to be a loadable
> module in this case, but the easiest fix seems to be to always enable
> MLXFW as well, like we do for CONFIG_MLXSW_SPECTRUM, which is the other
> user of mlxfw_firmware_flash.

We would not want to force mlx5 users to build mlxfw.

So lets either use the more elaborate method or maybe instead of using
IS_ENABLED in mlxfw.h use IS_REACHABLE (this was suggested by Jakub)

Or.
