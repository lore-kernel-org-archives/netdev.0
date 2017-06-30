From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] [net-next] net/mlx5: include wq.o in non-ethernet build
 for FPGA
Date: Fri, 30 Jun 2017 21:25:13 +0200
Message-ID: <CAK8P3a1N4=JVJ3vZxBWJRTe-iJz25tmWjigPZ+4=-Aod0dq13Q@mail.gmail.com>
References: <20170630154412.3575760-1-arnd@arndb.de> <AM4PR0501MB19409232F4E056237F2FAFFFDBD30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Kamal Heib <kamalh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AM4PR0501MB19409232F4E056237F2FAFFFDBD30-dp/nxUn679gfNUYDR5dMTsDSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 8:58 PM, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:

>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> index ca367445f864..50fe9e3c5dc2 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> @@ -9,7 +9,7 @@ mlx5_core-y :=        main.o cmd.o debugfs.o fw.o eq.o uar.o
>> pagealloc.o \
>>  mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
>>
>>  mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o
>> fpga/sdk.o \
>> -             fpga/ipsec.o
>> +             fpga/ipsec.o wq.o
>
> I believe we would prefer to move wq.o to mlx5_core-y.
> Otherwise you might build it twice.

That's not a problem, Kbuild is smart enough to drop duplicate object files
that get built into the same module.

If you think it's less confusing to readers of this file if it gets
put into core,
that's fine though, the only downside would be adding a little bit of
code bloat for users that want neither the ethernet nor the fpga code
(if that is a realistic use case).

        Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
