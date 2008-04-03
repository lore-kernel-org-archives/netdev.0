From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 0/5] fixup locking on m68knommu fec
Date: Thu, 03 Apr 2008 16:54:06 +1000
Message-ID: <47F47F0E.9030803@snapgear.com>
References: <20080402204417.597098190@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:40124 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756850AbYDCGyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 02:54:09 -0400
In-Reply-To: <20080402204417.597098190@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastian,

Sebastian Siewior wrote:
> This series basically fixes my locking problem. We have here:
> #1 the old one which removes some undefined vars.
> #2 cleans the file with lident. I had trouble reading the code...
> #3 type def a function pointer so we don't have the long defines
>    and move the callback after releasing the lock.
> #4 This one fixes the locking I guess. My mcf5235 did not race anymore
>    after that one. I saw 0a504779d while forming the patch so I guess
>    we could revert that one, Greg?

Yes, certainly we can.
I'd like to do some testing on this as well :-)


> #5 removes the registration of interrupt handlers & enabling interrupt
>    sources that are not handled. I stepped into this after I thought that
>    it is over :) Greg, Should we also remove that part where we enable
>    the irq controller (I though request_irq() is doing that).

Currently it doesn't. The main sticking point is what to do
with the hardware based priority setting logic. We don't really
rely on it, but they need to be set to sane values.

Need to expand the interrupt controller setup code some more
before we can take that out.

Regards
Greg



------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
Secure Computing Corporation                PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
