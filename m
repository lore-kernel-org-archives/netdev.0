From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [patch 3/8] sundance: remove TxStartThresh and RxEarlyThresh
Date: Mon, 23 Oct 2006 00:05:52 +0200
Message-ID: <20061022220552.GA1122@ingate.macqel.be>
References: <200610202142.k9KLg5W6003719@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:42019 "EHLO mail.macqel.be")
	by vger.kernel.org with ESMTP id S1750725AbWJVWFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2006 18:05:53 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200610202142.k9KLg5W6003719@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 02:42:05PM -0700, akpm@osdl.org wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> For patent issue need to remove TxStartThresh and RxEarlyThresh.  This patent
> is cut-through patent.  If use this function, Tx will start to transmit after
> few data be move in to Tx FIFO.  We are not allow to use those function in
> DFE530/DFE550/DFE580/DL10050/IP100/IP100A.  It will decrease a little
> performance.
[...]
> @@ -1111,6 +1109,7 @@ static irqreturn_t intr_handler(int irq,
>  	int tx_cnt;
>  	int tx_status;
>  	int handled = 0;
> +	int i;

What the use here of adding this variable ? Is that actually a part of another
patch ?

>  
>  
>  	do {
> @@ -1153,17 +1152,14 @@ static irqreturn_t intr_handler(int irq,
>  						np->stats.tx_fifo_errors++;
>  					if (tx_status & 0x02)
>  						np->stats.tx_window_errors++;
> +
>  					/*
>  					** This reset has been verified on
>  					** DFE-580TX boards ! phdm@macqel.be.
>  					*/
>  					if (tx_status & 0x10) {	/* TxUnderrun */
> -						unsigned short txthreshold;
> -
> -						txthreshold = ioread16 (ioaddr + TxStartThresh);
>  						/* Restart Tx FIFO and transmitter */
>  						sundance_reset(dev, (NetworkReset|FIFOReset|TxReset) << 16);
> -						iowrite16 (txthreshold, ioaddr + TxStartThresh);

I must be dense, but I do not understand how merely preserving the value of
a register across a reset can infringe on any patent

Philippe
