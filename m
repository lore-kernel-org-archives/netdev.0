From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH,try2 1/3] ep93xx_eth: fix RX/TXstatus ring full handling
Date: Tue, 31 Oct 2006 20:21:03 -0500
Message-ID: <4547F67F.5090806@garzik.org>
References: <20061030185231.GB14805@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43987 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1945969AbWKABVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 20:21:06 -0500
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20061030185231.GB14805@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> Ray Lehtiniemi reported that an incoming UDP packet flood can lock up
> the ep93xx ethernet driver.  Herbert Valerio Riedel noted that due to
> the way ep93xx_eth manages the RX/TXstatus rings, it cannot distinguish
> a full ring from an empty one, and correctly suggested that this was
> likely to be causing this lockup to occur.
> 
> Instead of looking at the hardware's RX/TXstatus ring write pointers
> to determine when to stop reading from those rings, we should just check
> every individual RX/TXstatus descriptor's valid bit instead, since there
> is no other way to distinguish an empty ring from a full ring, and if
> there is a descriptor waiting, we take the hit of reading the descriptor
> from memory anyway.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

applied 1-3


