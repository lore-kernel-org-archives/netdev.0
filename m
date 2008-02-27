From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [resend]The kernel gets no IP from some DHCP servers,
 2.6.24
Date: Wed, 27 Feb 2008 13:46:55 +0100
Message-ID: <47C55BBF.7080501@trash.net>
References: <83116F0A4FF67A4F97BA0B6E408C48E301C5CDEF@zuerich.BC-Int.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, ebiederman@lnxi.com
To: Wappler Marcel <Marcel.Wappler@bridgeco.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:34949 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbYB0Mqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 07:46:51 -0500
In-Reply-To: <83116F0A4FF67A4F97BA0B6E408C48E301C5CDEF@zuerich.BC-Int.NET>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wappler Marcel wrote:
> --- linux-2.6.24.2/net/ipv4/ipconfig.c	2008-02-21 15:27:47.250890963 +0100
> +++ linux/net/ipv4/ipconfig.c	2008-02-21 15:36:12.686735925 +0100
> @@ -29,6 +29,10 @@
>   *
>   *  Multiple Nameservers in /proc/net/pnp
>   *              --  Josef Siemes <jsiemes@web.de>, Aug 2002
> + *
> + *  Bugfix: Not getting an IP from some DHCP servers: RFC2131 page 36
> + *  Table 5 requests DHCPDISCOVER fields ciaddr and siaddr MUST be '0'.
> + *              -- marcel.wappler@bridgeco.net
>   */

Please don't add changelogs to source files, git keeps track of
them.

>  #include <linux/types.h>
> @@ -103,6 +107,7 @@
>  					   - '3' from resolv.h */
>  
>  #define NONE __constant_htonl(INADDR_NONE)
> +#define ZERO __constant_htonl(((unsigned long int) 0x00000000))

This should probably use INADDR_ANY.
