From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Make in-kernel hostap less annoying
Date: Thu, 15 Jun 2006 10:07:47 -0400
Message-ID: <1150380468.2323.2.camel@localhost.localdomain>
References: <20060612191302.GD32443@skunkworks.cabal.ca>
	 <20060615034102.GF9611@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kyle McMartin <kyle@parisc-linux.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53987 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751428AbWFOOHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 10:07:36 -0400
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20060615034102.GF9611@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-14 at 20:41 -0700, Jouni Malinen wrote: 
> On Mon, Jun 12, 2006 at 03:13:02PM -0400, Kyle McMartin wrote:
> 
> > Most user don't want their kern.log/dmesg filled with
> > debugging gibberish, and could turn it on if prompted.
> > 
> > ( Example:
> > wifi0: TXEXC - status=0x0004 ([Discon]) tx_control=000c
> > retry_count=0 tx_rate=0 fc=0x0108 (Data::0 ToDS)
> > A1=00:0f:66:43:d7:0a A2=00:05:3c:06:63:01 A3=33:33:00:00:00:16 
> > A4=00:00:00:00:00:00 )
> 
> I agree with removing these by default. However, I would prefer to do
> this in more selective manor than disabling all debugging information at
> build time. This would probably involve going through all debug messages
> using this mechanism and selecting whether they are reasonable to enable
> by default or not and ideally doing this as a run-time option.
> 
> > Also make hostap default to managed mode, instead of master mode, which
> > has bitten a few users expecting it to behave like the orinoco driver
> > it is replacing.
> 
> NAK. Host AP has been configured to use master mode by default for the
> past six years and that is what most users would expect it to continue
> to do. I do understand that this default differs from all drivers that
> do not support AP mode, but I think it is too late to change this now.
> The default could change once Host AP gets replaced with
> net/d80211-based implementation for Prism2/2.5/3, but I would not change
> this for Host AP driver.

Furthermore, if your network scripts and/or network daemon don't know to
change the card to Managed mode before they starts trying to make a
connection, they need to be fixed.  It shouldn't really matter to users
what mode the driver starts up in, since the mode needs to get
unconditionally set on the card anyway for each connection you try to
make.  That doesn't matter if it's a human or a script.

Dan


