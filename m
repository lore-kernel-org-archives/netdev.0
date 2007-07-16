From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in
 free_shared_mem() in drivers/net/s2io.c
Date: Mon, 16 Jul 2007 17:56:24 -0400
Message-ID: <469BE988.6090907@pobox.com>
References: <aaab98560707082029u52ffce5eia32cfb57a29db78f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36946 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761795AbXGPV42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 17:56:28 -0400
In-Reply-To: <aaab98560707082029u52ffce5eia32cfb57a29db78f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micah Gruber wrote:
> This patch fixes a potential null dereference bug where we dereference
> nic before a null check. This patch simply moves the dereferencing
> after the null check.
> 
> Signed-off-by: Micah Gruber < micah.gruber@gmail.com>
> 
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -789,12 +789,14 @@
>        struct mac_info *mac_control;
>        struct config_param *config;
>        int lst_size, lst_per_page;
> -       struct net_device *dev = nic->dev;
> +       struct net_device *dev;
>        int page_num = 0;
> 
>        if (!nic)
>                return;
> 
> +       dev = nic->dev;
> +

applied manually -- all of your patch attempts produced corrupted patches :/


