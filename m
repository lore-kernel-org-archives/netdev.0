From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] add driver for enc28j60 ethernet chip
Date: Mon, 17 Dec 2007 18:49:14 -0500
Message-ID: <47670AFA.1000608@pobox.com>
References: <475EA546.7030202@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34534 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934430AbXLQXtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:49:17 -0500
In-Reply-To: <475EA546.7030202@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Claudio Lanconelli wrote:
> These patches add support for Microchip enc28j60 ethernet chip 
> controlled via SPI.
> I tested it on my custom board (S162) with ARM9 s3c2442 SoC.
> Any comments are welcome.
> 
> Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>


comments:

* overall:  a clean driver that looks mostly acceptable, good work

* use stats in net_device rather than defining your own

* use ethtool rather than 'full_duplex' variable to select duplex

* [suggestion but not requirement] kernel prefers "u8" and "u32" types 
to the C99 types uint8_t or uint32_t

* remove the 'inline' markers from functions, and let the compiler make 
the decision

* udelay() in enc28j60_phy_write() -- and any similar code pattern -- 
may not actually delay for the specified amount of time, when you 
consider that writes may be posted.  normally a read will flush a write.

* Why do interrupt work in a kernel thread?  Your comment says you 
cannot, but does not explain.

* should use NAPI

* should be able to program multicast list while everything is active


