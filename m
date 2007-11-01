From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 2/2] [POWERPC] Fix region size check in mpc5200 FEC driver
Date: Thu, 1 Nov 2007 19:13:55 +0100
Message-ID: <200711011913.55525.netdev@axxeo.de>
References: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net> <20071101142235.7620.36853.stgit@trillian.cg.shawcable.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, domen.puncer@telargo.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:3578 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858AbXKASPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 14:15:37 -0400
In-Reply-To: <20071101142235.7620.36853.stgit@trillian.cg.shawcable.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Grant,

Grant Likely schrieb:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> Driver shouldn't complain if the register range is larger than what
> it expects.  This works around failures with some device trees.
> 

But maybe the firmware guys like to know about it?
May I suggest putting this in front of the other check?

if ((mem.end - mem.start + 1) > sizeof(struct mpc52xx_fec)) {
  		printk(KERN_DEBUG DRIVER_NAME
			" - gratious resource size (%lx > %x), check mpc52xx_devices.c\n",
  			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
}

> -	if ((mem.end - mem.start + 1) != sizeof(struct mpc52xx_fec)) {
> +	if ((mem.end - mem.start + 1) < sizeof(struct mpc52xx_fec)) {
>  		printk(KERN_ERR DRIVER_NAME
> -			" - invalid resource size (%lx != %x), check mpc52xx_devices.c\n",
> +			" - invalid resource size (%lx < %x), check mpc52xx_devices.c\n",
>  			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
>  		return -EINVAL;
>  	}


Best Regards

Ingo Oeser
