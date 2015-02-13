From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 13:37:58 +0300
Message-ID: <54DDD406.7030609@cogentembedded.com>
References: <1423798552-7091-1-git-send-email-Yanjun.Zhu@windriver.com> <1423798552-7091-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>, netdev@vger.kernel.org,
	mst@redhat.com, jasowang@redhat.com, viro@zeniv.linux.org.uk,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:38300 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbbBMKiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 05:38:01 -0500
Received: by lamq1 with SMTP id q1so15474301lam.5
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 02:38:00 -0800 (PST)
In-Reply-To: <1423798552-7091-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/13/2015 6:35 AM, Zhu Yanjun wrote:

> The default speed of normal nic is 1000M while the default speed
> of tun is 10M. Now the default speed of tun is changed to 1000M.
> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
> The command "ethtool -s tun0 speed 10/100/1000" can configure the
> speed of tun dynamically.

> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>   drivers/net/tun.c           | 42 +++++++++++++++++++++++++++++++++++++++++-
>   include/uapi/linux/if_tun.h |  5 +++++
>   2 files changed, 46 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8c8dc16..0ee36f1 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
[...]
> @@ -2257,9 +2260,18 @@ static struct miscdevice tun_miscdev = {
>
>   static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>   {
> +	struct tun_struct *tun = netdev_priv(dev);
> +
> +	/* Get the speed of tun */
> +	if (tun->flags & TUN_CTRL_SPD_1000) {
> +		ethtool_cmd_speed_set(cmd, SPEED_1000);
> +	} else if (tun->flags & TUN_CTRL_SPD_100) {
> +		ethtool_cmd_speed_set(cmd, SPEED_100);
> +	} else
> +		ethtool_cmd_speed_set(cmd, SPEED_10);

    I probably missed it in the previous version: {} not needed here at all. 
Please remove to comply with Documentation/CodingStyle.

[...]

WBR, Sergei
