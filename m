From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH NEXT 02/10] qlcnic: add api version in reg dump
Date: Tue, 31 Aug 2010 16:26:45 +0100
Message-ID: <1283268405.2244.4.camel@achroite.uk.solarflarecom.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
	 <1283264980-25881-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43095 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932372Ab0HaP0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 11:26:48 -0400
In-Reply-To: <1283264980-25881-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-31 at 07:29 -0700, Amit Kumar Salecha wrote:
[...]
> @@ -345,7 +346,10 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
>  	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
>  	    (adapter->pdev)->device;
>  
> -	for (i = 0; diag_registers[i] != -1; i++)
> +	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
> +	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
> +
> +	for (i = 2; diag_registers[i] != -1; i++)
>  		regs_buff[i] = QLCRD32(adapter, diag_registers[i]);
>  
>  	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))

You should either bump the version number or put this extra information
at the end of the register dump, not the beginning.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

