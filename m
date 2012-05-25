From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Fri, 25 May 2012 11:58:20 -0400
Message-ID: <20120525155820.GA25102@windriver.com>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com>
 <20120522.151830.2018953337014839778.davem@davemloft.net>
 <4FBE4E02.1070306@computer.org>
 <1337876210.5070.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jan Ceuleers <jan.ceuleers@computer.org>,
	David Miller <davem@davemloft.net>, <b06378@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50244 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab2EYP6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 11:58:41 -0400
Content-Disposition: inline
In-Reply-To: <1337876210.5070.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH] gianfar:don't add FCB length to hard_header_len] On 24/05/2012 (Thu 09:16) Joe Perches wrote:

> On Thu, 2012-05-24 at 17:04 +0200, Jan Ceuleers wrote:
> > On 05/22/2012 09:18 PM, David Miller wrote:
> > > From: Jiajun Wu <b06378@freescale.com>
> > > Date: Tue, 22 May 2012 17:00:48 +0800
> > > 
> > >> FCB(Frame Control Block) isn't the part of netdev hard header.
> > >> Add FCB to hard_header_len will make GRO fail at MAC comparision stage.
> > >>
> > >> Signed-off-by: Jiajun Wu <b06378@freescale.com>
> > > 
> > > Applied, thanks.
> > > 
> > > Someone needs to go through this driver when net-next opens up
> > > and fix all of the indentation in this driver.
> > 
> > May I give that a go?
> 
> I have scripts that automate most of this.
> I don't have the card though.

There is no card.  The gianfar is a SOC for freescale 83xx, 85xx, 86xx
CPUs.  If need be, I can test just as I did for your name overrun fix
in commit 0015e551e.

But you really shouldn't need the hardware to validate this kind of
patch anyways -- aside from your code flow change in the irq routine of
gianfar_ptp, you should have been simply able to check for object file
equivalence before and after your change.

Paul.

> 
> Maybe this is a starting point?
> It doesn't fix most 80 column warnings.
> 
>  drivers/net/ethernet/freescale/gianfar.c         |  299 +++++++++++-----------
>  drivers/net/ethernet/freescale/gianfar_ethtool.c |  131 +++++-----
>  drivers/net/ethernet/freescale/gianfar_ptp.c     |    8 +-
>  drivers/net/ethernet/freescale/gianfar_sysfs.c   |    2 +-
>  4 files changed, 225 insertions(+), 215 deletions(-)
> 

[...]

> diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
> index c08e5d4..3f7b81d 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ptp.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
> @@ -268,11 +268,11 @@ static irqreturn_t isr(int irq, void *priv)
>  		ptp_clock_event(etsects->clock, &event);
>  	}
>  
> -	if (ack) {
> -		gfar_write(&etsects->regs->tmr_tevent, ack);
> -		return IRQ_HANDLED;
> -	} else
> +	if (!ack)
>  		return IRQ_NONE;
> +
> +	gfar_write(&etsects->regs->tmr_tevent, ack);
> +	return IRQ_HANDLED;
>  }
>  
>  /*
