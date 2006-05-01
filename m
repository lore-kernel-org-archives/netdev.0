From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tw32_f() in tg3_write_mem()
Date: Mon, 01 May 2006 07:53:04 -0700
Message-ID: <1146495184.4780.33.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC041BBEE@NT-IRVA-0751.brcm.ad.broadcom.com>
 <20060430.230719.90327967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:27147 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932145AbWEAQdJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 12:33:09 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060430.230719.90327967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-04-30 at 23:07 -0700, David S. Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Sun, 30 Apr 2006 22:05:40 -0700
> 
> > Reading back the data register is a safe thing to do. This
> > guarantees that the data is written before we change the address
> > register to the zero value. Without the read, there is a danger of
> > the value being written to SRAM address 0 instead of the desired
> > address.
> 
> Writes can be posted, but they cannot be reordered can they?
> 

Right, reordering is not allowed unless the relaxed ordering attribute
is set. The read back here is not to guarantee ordering. Those SRAM
address and data registers require "set-up" times for the SRAM writes
and reads to work correctly. The "set-up" times are met either with
config. cycles or with a read when using MMIO cycles. No udelays are
needed, just a read will do.

