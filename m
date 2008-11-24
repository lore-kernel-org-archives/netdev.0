From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netdev: generate kobject uevent on network events.
Date: Mon, 24 Nov 2008 20:06:14 +0000
Message-ID: <1227557174.3162.7.camel@achroite>
References: <20081121234110.22b47154@extreme>
	 <ac3eb2510811220608y33662b0bkb66026c2a21b061e@mail.gmail.com>
	 <F6B63A37-A69F-4197-B7E5-C9FD9BFA76F6@holtmann.org>
	 <20081122223249.4be03e4e@extreme>
	 <ac3eb2510811230813s3cb5c248k1e15d9ece581c8ad@mail.gmail.com>
	 <20081124114522.1e8de3fe@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	David Miller <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:46699 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752272AbYKXUGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 15:06:20 -0500
In-Reply-To: <20081124114522.1e8de3fe@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-24 at 11:45 -0800, Stephen Hemminger wrote:
[...]
> +	case NETDEV_CHANGE:
> +		if (netif_running(netdev)) {
> +			char str[64] = "DEVSTATE=UP";
> +			char *envp[2] = { str, NULL };
> +
> +			if (netif_oper_up(netdev))
> +				strcat(str, ",RUNNING");
> +			if (netif_carrier_ok(netdev))
> +				strcat(str, ",LOWER_UP");
> +			if (netif_dormant(netdev))
> +				strcat(str, ",DORMANT");
> +			kobject_uevent_env(&netdev->dev.kobj, KOBJ_CHANGE, envp);
> +		}
> +		break;

Unless I'm much mistaken, NETDEV_CHANGE should only be generated when
netif_running() is true, so the test is redundant.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

