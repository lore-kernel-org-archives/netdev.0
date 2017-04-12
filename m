From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 15:10:08 +0200
Message-ID: <20170412131008.GC32596@lunn.ch>
References: <f43dda26d3c43fdf19d6872306741c16b635558c.1491989111.git.jpinto@synopsys.com>
 <20170412115643.GA32596@lunn.ch>
 <d5e99129-eef0-1d15-7277-e3c82435bf9f@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56441 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751685AbdDLNKO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 09:10:14 -0400
Content-Disposition: inline
In-Reply-To: <d5e99129-eef0-1d15-7277-e3c82435bf9f@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> +- snps,drop-tx-status: this enables drop tx status
> > 
> > Hi Joao
> > 
> > Was the conclusion from testing that this cannot be turned on by
> > default?
> 
> This feature is great for applications that need good performance, but has a
> drawback since it has an impact in timestamp feature in Tx. There are some
> operations in PTP where the timestamp is given to the host through the TX status
> in the descriptor, so this will have an impact.
> 
> There's a way of solving this of course by making the driver checking the
> timestamp in the MAC_Tx_Timestamp_Status_XXX registers, but I can only look into
> that feature later in the future.

The problem you have is that the device tree binding is a Binary API
you have to keep backwards compatible with for the next 20 years. You
cannot drop this property when you do get around to finishing the
work. You also want to avoid adding more and more options, which
nobody knows what they do, and what best combination is to get the
best performance. You should be aiming for a driver which just works
without any configuration and with good performance.

> > What sort of performance improvement did you get? Do you have some
> > benchmark numbers?
> 
> My setup is FPGA based, so it will have lower performance values.
> Iperf results with
>   "Drop Transmit Status" set: ~650Mbps.
>   "Drop Transmit Status" unset: ~450Mbps.

What percentage of your customers use FPGAs? When i look at the users
of this driver, i see ST, Allwinner, Rockchip, Meson, etc. So silicon,
not FPGA. Does it make sense to do performance measurements on FPGA,
when you say it has lower performance?

     Andrew
