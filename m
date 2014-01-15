From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH net-next 2/3] virtio_net: Introduce one dummy function virtnet_filter_rfs()
Date: Wed, 15 Jan 2014 09:54:36 -0800
Message-ID: <CA+mtBx8Z80d5Y1ti0_68UA-x0hZPeqT4wa9knevWoPxX+eyaVA@mail.gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	<1389795654-28381-3-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:56222 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbaAORyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 12:54:37 -0500
Received: by mail-ig0-f178.google.com with SMTP id uq10so5204243igb.5
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 09:54:36 -0800 (PST)
In-Reply-To: <1389795654-28381-3-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhi, this is promising work! I can't wait to see how this impacts
network virtualization performance :-)

On Wed, Jan 15, 2014 at 6:20 AM, Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  drivers/net/virtio_net.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 7b17240..046421c 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1295,6 +1295,14 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>         return 0;
>  }
>
> +#ifdef CONFIG_RFS_ACCEL
> +static int virtnet_filter_rfs(struct net_device *net_dev,
> +               const struct sk_buff *skb, u16 rxq_index, u32 flow_id)
> +{
Does this need to be filled out with more stuff?

> +       return 0;
> +}
> +#endif /* CONFIG_RFS_ACCEL */
> +
>  static const struct net_device_ops virtnet_netdev = {
>         .ndo_open            = virtnet_open,
>         .ndo_stop            = virtnet_close,
> @@ -1309,6 +1317,9 @@ static const struct net_device_ops virtnet_netdev = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>         .ndo_poll_controller = virtnet_netpoll,
>  #endif
> +#ifdef CONFIG_RFS_ACCEL
> +       .ndo_rx_flow_steer   = virtnet_filter_rfs,
> +#endif
>  };
>
>  static void virtnet_config_changed_work(struct work_struct *work)
> --
> 1.7.6.5
>
