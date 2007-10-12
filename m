From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [NET] MIPSsim: General cleanup
Date: Fri, 12 Oct 2007 19:05:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710121859510.23443@kivilampi-30.cs.helsinki.fi>
References: <20071012135956.GA16163@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, Netdev <netdev@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57236 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757454AbXJLQFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 12:05:19 -0400
In-Reply-To: <20071012135956.GA16163@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007, Ralf Baechle wrote:

> General cleanups mostly as suggested by checkpatch plus getting rid of
> homebrew version of offsetof().
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> ---
> 
>  drivers/net/mipsnet.c |   63 ++++++++++++++++++-------------------
>  drivers/net/mipsnet.h |   83 ++++++++++++++++++++++++++------------------------
>  2 files changed, 75 insertions(+), 71 deletions(-)
> 
> diff --git a/drivers/net/mipsnet.h b/drivers/net/mipsnet.h
> index 026c732..0132c67 100644
> --- a/drivers/net/mipsnet.h
> +++ b/drivers/net/mipsnet.h
>  
>  #define MIPSNET_IO_EXTENT 0x40	/* being generous */
>  
> -#define field_offset(field) ((int)&((MIPS_T_NetControl*)(0))->field)
> +#define field_offset(field) (offsetof(struct net_control_block, field))

Is there any value in keeping this macro... why don't you just remote it?
There's seems to be just one user of it anyway:

drivers/net/mipsnet.c:#define mipsnet_reg_address(dev, field) (dev->base_addr + field_offset(field))


-- 
 i.
