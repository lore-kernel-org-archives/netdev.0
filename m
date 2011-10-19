From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH net] vlan:make mtu of vlan equal to physical dev
Date: Wed, 19 Oct 2011 10:06:48 +0800
Message-ID: <4E9E30B8.5030904@gmail.com>
References: <bc33a6142ce48b71b9c232a9154ed76f6048f0cb.1318068629.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39041 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab1JSCFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 22:05:09 -0400
Received: by wyg36 with SMTP id 36so1233802wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 19:05:08 -0700 (PDT)
In-Reply-To: <bc33a6142ce48b71b9c232a9154ed76f6048f0cb.1318068629.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Herbert,

What do you think of this patch ?

thanks
Weiping Pan
On 10/08/2011 06:12 PM, Weiping Pan wrote:
> Default mtu of vlan device is the same with mtu of physical device,
> for example 1500, but when change physics mtu to 1600,
> VLAN device's mtu is still 1500.
> Certainly, you can change vlan device's mtu to 1600 manually,
> but I think when you change physics device's mtu, VLAN's mtu should be changed
> automatically instead of by manually.
>
> Steps to Reproduce:
> 1.vconfig add eth4 3
> 2.ifconfig eth4 mtu 1600
> 3.check mtu on eth4.3
>
> And what's worse is that if you decrease mtu of pyhsical device,
> and when you want to increase it, the mtu of vlan device won't be changed.
>
> Steps to Reproduce:
> 1.vconfig add eth4 3
> 2.ifconfig eth4 mtu 100
> 3.ifconfig eth4 mtu 1500
> 4.the mtu of eth4.3 is still 100
>
> This bug is reported by Liang Zheng(lzheng@redhat.com).
>
> Signed-off-by: Weiping Pan<panweiping3@gmail.com>
> ---
>   net/8021q/vlan.c |    3 ---
>   1 files changed, 0 insertions(+), 3 deletions(-)
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 8970ba1..f6072b4 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -417,9 +417,6 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
>   			if (!vlandev)
>   				continue;
>
> -			if (vlandev->mtu<= dev->mtu)
> -				continue;
> -
>   			dev_set_mtu(vlandev, dev->mtu);
>   		}
>   		break;
