From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [net-next] net/mlx5e: select CONFIG_MLXFW
Date: Thu, 29 Jun 2017 09:48:57 +0200
Message-ID: <CAK8P3a1R3jP-qes5ZbbM4xETGvrCzdNahXENPqmXyh9+Xy-ipw@mail.gmail.com>
References: <20170628201032.3178691-1-arnd@arndb.de> <CAJ3xEMj3GdWbUGm8DrMhoc282FoGE9f7XxZB8tauz1J_gdK-_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMj3GdWbUGm8DrMhoc282FoGE9f7XxZB8tauz1J_gdK-_A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2017 at 5:47 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Wed, Jun 28, 2017 at 11:10 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> With the introduction of mlx5 firmware flash support, we get a link
>> error with CONFIG_MLXFW=m and CONFIG_MLX5_CORE=y:
>>
>> drivers/net/ethernet/mellanox/mlx5/core/fw.o: In function `mlx5_firmware_flash':
>> fw.c:(.text+0x9d4): undefined reference to `mlxfw_firmware_flash'
>
> Thanks Arnd, I got a report on that from Jakub but you were before me here..
>
>> We could have a more elaborate method to force MLX5 to be a loadable
>> module in this case, but the easiest fix seems to be to always enable
>> MLXFW as well, like we do for CONFIG_MLXSW_SPECTRUM, which is the other
>> user of mlxfw_firmware_flash.
>
> We would not want to force mlx5 users to build mlxfw.
>
> So lets either use the more elaborate method or maybe instead of using
> IS_ENABLED in mlxfw.h use IS_REACHABLE (this was suggested by Jakub)

Sure, that works. I generally try to avoid IS_REACHABLE(), as I find it more
confusing than adding a dependency like

           depends on MLXFW || MLXFW=n

(and yes, I was the one who introduced IS_REACHABLE() ;-) ).

      Arnd
