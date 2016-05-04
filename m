From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH 3/3] net/mlx5e: don't build RFS without ethernet
Date: Wed, 4 May 2016 17:55:20 +0300
Message-ID: <CALzJLG9NnqPmm1TpdKub3u=bPRWDDevJh0=oECz0m1O-caqAzw@mail.gmail.com>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
 <1462365155-3861405-1-git-send-email-arnd@arndb.de> <CALzJLG9j6ZodwDToX8iuvNVKLoMoaM8V9w8cFR6jM-ktU0ynHg@mail.gmail.com>
 <6481938.m1ihicFdKr@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Matthew Finlay <matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramonvsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6481938.m1ihicFdKr@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 4, 2016 at 5:23 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Wednesday 04 May 2016 16:09:16 Saeed Mahameed wrote:
>> On Wed, May 4, 2016 at 3:32 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
>> > The RFS acceleration support in mlx5 is enabled whenever CONFIG_RFS_ACCEL
>> > is in use. However, this fails if a user turns off CONFIG_MLX5_CORE_EN,
>> > because the rfs code now calls into the ethernet portion of the
>> > driver:
>> >
>> > ERROR: "mlx5e_destroy_flow_table" [drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko] undefined!
>> >
>>
>> Hi Arnd,
>>
>> We already posted a fix for this, please see "[PATCH net-next V1
>> 01/12] net/mlx5e: Fix aRFS compilation dependency", and give us your
>> feedback.
>
> That version looks fine as well. I think it's better to be a little
> more explicit as I was, but either way seems fine.
>

Simply we didn't want to add new Kconfig flag.

>
> You can also achieve the same thing in yet another way using Makefile
> syntax instead of cpp or Kconfig:
>
> ifdef CONFIG_MLX5_CORE_EN
> mlx5_core-y += wq.o eswitch.o \
>                en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
>                en_txrx.o en_clock.o vxlan.o en_tc.o
>                en_txrx.o en_clock.o vxlan.o en_tc.o en_arfs.o
>
> mlx5_core-$(CONFIG_RFS_ACCEL) += en_arfs.o
> endif
>
>
> If you prefer Maor's version, feel free to add
>
>
> Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
>

I do prefer this version, but the difference is small, so will keep Maor's.
Thanks Arnd for the Ack and the suggestion.

Saeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
