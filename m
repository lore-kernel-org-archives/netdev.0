From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] [net-next] net/mlx5: include wq.o in non-ethernet build
 for FPGA
Date: Mon, 3 Jul 2017 09:21:53 +0200
Message-ID: <CAK8P3a3B_-0-7BhbJG_Dni7qpNwy5qNgBeKW2X7R7V6Bujf4zQ@mail.gmail.com>
References: <20170630154412.3575760-1-arnd@arndb.de> <AM4PR0501MB19409232F4E056237F2FAFFFDBD30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CAK8P3a1N4=JVJ3vZxBWJRTe-iJz25tmWjigPZ+4=-Aod0dq13Q@mail.gmail.com> <CALzJLG8TR8qmBygiL7Eg-1tWvOEgDvtECxKaXt4=j4YdCN72xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
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
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG8TR8qmBygiL7Eg-1tWvOEgDvtECxKaXt4=j4YdCN72xA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 2, 2017 at 10:45 AM, Saeed Mahameed
<saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> On Fri, Jun 30, 2017 at 10:25 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
>> On Fri, Jun 30, 2017 at 8:58 PM, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>>
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>>> b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>>> index ca367445f864..50fe9e3c5dc2 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>>> @@ -9,7 +9,7 @@ mlx5_core-y :=        main.o cmd.o debugfs.o fw.o eq.o uar.o
>>>> pagealloc.o \
>>>>  mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
>>>>
>>>>  mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o
>>>> fpga/sdk.o \
>>>> -             fpga/ipsec.o
>>>> +             fpga/ipsec.o wq.o
>>>
>>> I believe we would prefer to move wq.o to mlx5_core-y.
>>> Otherwise you might build it twice.
>>
>> That's not a problem, Kbuild is smart enough to drop duplicate object files
>> that get built into the same module.
>>
>> If you think it's less confusing to readers of this file if it gets
>> put into core,
>> that's fine though, the only downside would be adding a little bit of
>> code bloat for users that want neither the ethernet nor the fpga code
>> (if that is a realistic use case).
>
> Hi Arnd,
>
> Thanks for the patch, your solution is good enough, but let's avoid
> confusing developers with such duplications.
> since the Makefile might get messy if we will keep using this method.
>
> I suggest to move wq.o to core or make MLX5_FPGA depend on MLX5_CORE_EN.
> I will discuss this with Ilan and we will provide the fix ASAP.

Ok, sounds good. Thanks!

    Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
