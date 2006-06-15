From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] Make in-kernel hostap less annoying
Date: Wed, 14 Jun 2006 20:41:02 -0700
Message-ID: <20060615034102.GF9611@jm.kir.nu>
References: <20060612191302.GD32443@skunkworks.cabal.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:26538 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP id S932426AbWFODlr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 23:41:47 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060612191302.GD32443@skunkworks.cabal.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 03:13:02PM -0400, Kyle McMartin wrote:

> Most user don't want their kern.log/dmesg filled with
> debugging gibberish, and could turn it on if prompted.
> 
> ( Example:
> wifi0: TXEXC - status=0x0004 ([Discon]) tx_control=000c
> retry_count=0 tx_rate=0 fc=0x0108 (Data::0 ToDS)
> A1=00:0f:66:43:d7:0a A2=00:05:3c:06:63:01 A3=33:33:00:00:00:16 
> A4=00:00:00:00:00:00 )

I agree with removing these by default. However, I would prefer to do
this in more selective manor than disabling all debugging information at
build time. This would probably involve going through all debug messages
using this mechanism and selecting whether they are reasonable to enable
by default or not and ideally doing this as a run-time option.

> Also make hostap default to managed mode, instead of master mode, which
> has bitten a few users expecting it to behave like the orinoco driver
> it is replacing.

NAK. Host AP has been configured to use master mode by default for the
past six years and that is what most users would expect it to continue
to do. I do understand that this default differs from all drivers that
do not support AP mode, but I think it is too late to change this now.
The default could change once Host AP gets replaced with
net/d80211-based implementation for Prism2/2.5/3, but I would not change
this for Host AP driver.

> Two minor things I've been carrying around in my personal tree
> for quite some time. (This is only relevant to the in-kernel driver,
> I see no reason to change the out-of-tree driver.)

That would be even more confusing for the default mode.. I believe that
both versions should continue to use Master mode as the default unless
overridden by user.

-- 
Jouni Malinen                                            PGP id EFC895FA
