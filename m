From: Joe Perches <joe@perches.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 18 Dec 2009 23:14:52 -0800
Message-ID: <1261206893.30458.65.camel@Joe-Laptop.home>
References: <200912190128.nBJ1SZww015431@blc-10-2.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Debashis Dutt <ddutt@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1294 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbZLSHOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Dec 2009 02:14:55 -0500
In-Reply-To: <200912190128.nBJ1SZww015431@blc-10-2.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 17:28 -0800, Debashis Dutt wrote:
> +static void bnad_hw_error(struct bnad *bnad, u8 status)
> +{
> +	char message[BNA_MESSAGE_SIZE];
[]
> +			sprintf(message, "Disabling Mbox IRQ %d for port %d",
> +				irq, bnad->bna_id);
> +		pr_info("%s",
> +				message);

All of the char message[BNA_MESSAGE_SIZE] declarations
are not necessary.

These messages are also missing trailing '\n' newlines.

It's better to not indirect via a buffer and simply use:

	pr_<level>("fmt\n", args);

