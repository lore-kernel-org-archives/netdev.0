From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/1] bridge: turn off carrier when the bridge is created
Date: Wed, 11 Mar 2015 10:39:53 +0800
Message-ID: <54FFAAF9.3000207@windriver.com>
References: <1425971382-14177-1-git-send-email-Yanjun.Zhu@windriver.com> <1425971382-14177-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <davem@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56069 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbCKCjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 22:39:51 -0400
In-Reply-To: <1425971382-14177-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stephen && David

Any comment?

Best Regards!
Zhu Yanjun
On 03/10/2015 03:09 PM, Zhu Yanjun wrote:
> When a bridge interface is created, there is no any sub interface
> in it. In this case, the packets should not go to this bridge interface.
> As such, carrier is turned off.
>
> CC: David Ahern <dsahern@gmail.com>
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>   net/bridge/br_device.c | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index ffd379d..fcc4794 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -394,4 +394,8 @@ void br_dev_setup(struct net_device *dev)
>   	br_netfilter_rtable_init(br);
>   	br_stp_timer_init(br);
>   	br_multicast_init(br);
> +
> +	/* Shutdown bridge to avoid packets */
> +	if (netif_carrier_ok(dev))
> +		netif_carrier_off(dev);
>   }
