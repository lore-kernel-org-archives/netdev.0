From: Amit Kale <amitkale@netxen.com>
Subject: Re: [PATCH] netxen: do_rom_fast_write error handling
Date: Tue, 27 Feb 2007 12:11:02 +0530
Message-ID: <200702271211.02344.amitkale@netxen.com>
References: <20070226145156.5c0424a3@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4937 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932847AbXB0Gkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 01:40:42 -0500
In-Reply-To: <20070226145156.5c0424a3@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ah.. missed that.
Thanks.
-Amit

On Tuesday 27 February 2007 04:21, Stephen Hemminger wrote:
> Compiler warning spots real error!
>
> The function do_rom_fast_read called in do_rom_fast_write can fail
> and leave data1 unset. This causes a compile warning.
> The correct thing is to propagate the error out.
>
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>
> ---
>  drivers/net/netxen/netxen_nic_init.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> --- pktgen.orig/drivers/net/netxen/netxen_nic_init.c	2007-02-26
> 14:45:46.000000000 -0800 +++
> pktgen/drivers/net/netxen/netxen_nic_init.c	2007-02-26 14:46:37.000000000
> -0800 @@ -499,7 +499,10 @@
>  		while(1) {
>  			int data1;
>
> -			do_rom_fast_read(adapter, addridx, &data1);
> +			ret = do_rom_fast_read(adapter, addridx, &data1);
> +			if (ret < 0)
> +				return ret;
> +
>  			if (data1 == data)
>  				break;
