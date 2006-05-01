From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tw32_f() in tg3_write_mem()
Date: Sun, 30 Apr 2006 22:05:40 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BBEE@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:27916 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750718AbWEAFFw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 01:05:52 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> At least for the TG3PCI_MEM_WIN_DATA register, I don't know how safe
> it is to use tw32_f() there.  Reads from a location can have side
> effects, so doing a forced readback after a write could be dangerous.
> 
> And it isn't needed, as the tw32_f() done as we set the
> TG3PCI_MEM_WIN_BASE_ADDR back to zero will flush all posted
> writes.
> 
> Agreed?
> 
> 

The TG3PCI_MEM_WIN_BASE_ADDR and DATA registers are very tricky. If you
do not read back the address register before you read or write the data
register, you may not read or write to the proper address.

Reading back the data register is a safe thing to do. This guarantees
that
the data is written before we change the address register to the zero
value. Without the read, there is a danger of the value being written to
SRAM address 0 instead of the desired address.

No additional reads are required if we use config. cycles on these
registers.

