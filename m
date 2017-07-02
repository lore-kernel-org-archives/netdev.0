From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] [net-next] net/mlx5: include wq.o in non-ethernet build
 for FPGA
Date: Sun, 2 Jul 2017 11:45:22 +0300
Message-ID: <CALzJLG8TR8qmBygiL7Eg-1tWvOEgDvtECxKaXt4=j4YdCN72xA@mail.gmail.com>
References: <20170630154412.3575760-1-arnd@arndb.de> <AM4PR0501MB19409232F4E056237F2FAFFFDBD30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CAK8P3a1N4=JVJ3vZxBWJRTe-iJz25tmWjigPZ+4=-Aod0dq13Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Boris Pismenny <borisp@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a1N4=JVJ3vZxBWJRTe-iJz25tmWjigPZ+4=-Aod0dq13Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 10:25 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Jun 30, 2017 at 8:58 PM, Ilan Tayari <ilant@mellanox.com> wrote:
>
>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> index ca367445f864..50fe9e3c5dc2 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> @@ -9,7 +9,7 @@ mlx5_core-y :=        main.o cmd.o debugfs.o fw.o eq.o uar.o
>>> pagealloc.o \
>>>  mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
>>>
>>>  mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o
>>> fpga/sdk.o \
>>> -             fpga/ipsec.o
>>> +             fpga/ipsec.o wq.o
>>
>> I believe we would prefer to move wq.o to mlx5_core-y.
>> Otherwise you might build it twice.
>
> That's not a problem, Kbuild is smart enough to drop duplicate object files
> that get built into the same module.
>
> If you think it's less confusing to readers of this file if it gets
> put into core,
> that's fine though, the only downside would be adding a little bit of
> code bloat for users that want neither the ethernet nor the fpga code
> (if that is a realistic use case).

Hi Arnd,

Thanks for the patch, your solution is good enough, but let's avoid
confusing developers with such duplications.
since the Makefile might get messy if we will keep using this method.

I suggest to move wq.o to core or make MLX5_FPGA depend on MLX5_CORE_EN.
I will discuss this with Ilan and we will provide the fix ASAP.

Thanks,
Saeed.


>
>         Arnd
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
