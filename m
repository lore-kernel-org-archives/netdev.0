From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netdevice: Fix wrong string handle in kernel command line parsing
Date: Mon, 30 Jun 2008 11:25:03 +0100
Message-ID: <20080630102502.GG4050@solarflare.com>
References: <48686D7A.9030200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:49192 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756717AbYF3KZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 06:25:10 -0400
Content-Disposition: inline
In-Reply-To: <48686D7A.9030200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> 1. In netdev_boot_setup_add(), a long name will leak.
>    ex. : dev=21,0x1234,0x1234,0x2345,eth123456789verylongname.........
> 2. In netdev_boot_setup_check(), mismatch will happen if s[i].name
>    is a substring of dev->name.
>    ex. : dev=...eth1 dev=...eth11

Well spotted, but...

> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c421a1f..9ecb3db 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -454,7 +454,7 @@ static int netdev_boot_setup_add(char *name, struct ifmap *map)
>  	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
>  		if (s[i].name[0] == '\0' || s[i].name[0] == ' ') {
>  			memset(s[i].name, 0, sizeof(s[i].name));
> -			strcpy(s[i].name, name);
> +			strncpy(s[i].name, name, IFNAMSIZ);

I think that strncpy() should be strlcpy(), because strncpy() does not
ensure null-termination.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
