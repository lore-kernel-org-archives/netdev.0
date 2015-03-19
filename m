From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Bluetooth: Fix use after free in l2cap_chan_timeout
Date: Thu, 19 Mar 2015 17:59:09 +0300
Message-ID: <550AE43D.8000705@cogentembedded.com>
References: <1426753191-9468-1-git-send-email-harish_kandiga@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gustavo@padovan.org, johan.hedberg@gmail.com, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Harish Jenny K N <harish_kandiga@mentor.com>, marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426753191-9468-1-git-send-email-harish_kandiga@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/19/2015 11:19 AM, Harish Jenny K N wrote:

> There is a potential use after free in bt_sock_poll when a
> socket gets killed without getting unlinked from accept_q.
> Hence added code to unlink from accpept_q by calling teardown
> before freeing the socket for channel type L2CAP_CHAN_CONN_ORIENTED.

> Signed-off-by: Harish Jenny K N <harish_kandiga@mentor.com>
> ---
>   net/bluetooth/l2cap_core.c |    5 +++++
>   1 file changed, 5 insertions(+)

> diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
> index 6ba33f9..c6955fb 100644
> --- a/net/bluetooth/l2cap_core.c
> +++ b/net/bluetooth/l2cap_core.c
> @@ -415,6 +415,11 @@ static void l2cap_chan_timeout(struct work_struct *work)
>
>   	l2cap_chan_close(chan, reason);
>
> +	if ((chan->state == BT_CONNECTED || chan->state == BT_CONFIG) &&
> +	    chan->chan_type == L2CAP_CHAN_CONN_ORIENTED) {
> +		chan->ops->teardown(chan, 0);
> +	}
> +

    {} not needed here.

[...]

WBR, Sergei
