From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH v2] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Tue, 26 Apr 2016 21:52:58 +0300
Message-ID: <CALzJLG_9bq_23xdg46d-tnus0Ohk95QQrRT1EbYJE-jv03A2WA@mail.gmail.com>
References: <1461685993-1049370-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Amir Vadai <amir-IB5XiEnQfqI@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461685993-1049370-1-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 6:52 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> struct mlx5e_channel_param is a large structure that is allocated
> on the stack of mlx5e_open_channels, and with a recent change
> it has grown beyond the warning size for the maximum stack
> that a single function should use:
>
> mellanox/mlx5/core/en_main.c: In function 'mlx5e_open_channels':
> mellanox/mlx5/core/en_main.c:1325:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
>
> The function is already using dynamic allocation and is not in
> a fast path, so the easiest workaround is to use another kzalloc
> for allocating the channel parameters.
>
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Fixes: d3c9bc2743dc ("net/mlx5e: Added ICO SQs")

Acked-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
