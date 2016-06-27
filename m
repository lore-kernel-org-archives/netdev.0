From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Tue, 28 Jun 2016 00:08:30 +0300
Message-ID: <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33992 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbcF0VIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 17:08:32 -0400
Received: by mail-oi0-f65.google.com with SMTP id s17so32910058oih.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 14:08:31 -0700 (PDT)
In-Reply-To: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 9:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> The stack doesn't trust the complete csum by hardware
> even when it is correct.

Can you explain that a little further?

> In the case we fix csum by ourself
> probably it is safe to just mark it as completed by software.

> This should shut up a kernel warning from netdev_rx_csum_fault()
> with mlx4 driver for ICMP packets.

can you point/paste the exact warning and how to reproduce that? is
that as simple as running ping and/or ping6?

> Fixes: f8c6455bb04b ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
> Cc: Shani Michaeli <shanim@mellanox.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index c1b3a9c..b44c434 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -732,6 +732,7 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
>                 if (get_fixed_ipv6_csum(hw_checksum, skb, hdr))
>                         return -1;
>  #endif
> +       skb->csum_complete_sw = 1;
>         return 0;
>  }
>
> --
> 2.1.0
>
