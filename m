From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH] Documentation: document the gianfar tx vlan offload issue
Date: Fri, 4 Apr 2014 11:07:29 +0800
Message-ID: <533E21F1.6020302@windriver.com>
References: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <claudiu.manoil@freescale.com>
To: <roy.qing.li@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:57204 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaDDDH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 23:07:29 -0400
In-Reply-To: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2014 11:04 AM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> The commit b852b72087[gianfar: fix bug caused by 87c288c6e9] and e2c53be223
> [gianfar: fix default tx vlan offload feature flag] disabled tx vlan offload
> from dev->feature, since enabling vlan tag insertion leads to unusable
> connections on some configurations.
>
> But this feature is in dev->hw_feature still, and a user can enable it by
> "ethtool", so document the tx vlan offload issue.
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Nice!

Zhu Yanjun
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>   Documentation/networking/gianfar.txt |   12 ++++++++++++
>   1 file changed, 12 insertions(+)
>
> diff --git a/Documentation/networking/gianfar.txt b/Documentation/networking/gianfar.txt
> index ad474ea..2d3dbe6 100644
> --- a/Documentation/networking/gianfar.txt
> +++ b/Documentation/networking/gianfar.txt
> @@ -51,6 +51,18 @@ configuring VLANs.  The gianfar driver supports hardware insertion and
>   extraction of VLAN headers, but not filtering.  Filtering will be
>   done by the kernel.
>   
> +But if tx vlan tag hardware insertion is enabled, and a vlan-device is
> +created, the physical device which vlan device is on will be unable to
> +work, like:
> +
> +	$ethtool -K eth0 tx-vlan-stag-hw-insert on
> +	$ifconfig eth0 192.168.1.13/24 up
> +
> +	$vconfig add eth0 4091
> +	$ifconfig eth0.4091 10.1.1.13/24 up
> +eth0.4091 can work, but eth0 can not work, since eth0 sends the insane
> +packets out.
> +
>   MULTICASTING
>   
>   The gianfar driver supports using the group hash table on the
