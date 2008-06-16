From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Mon, 16 Jun 2008 16:34:11 -0400
Message-ID: <4856CE43.4020706@garzik.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45605 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbYFPUeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 16:34:16 -0400
In-Reply-To: <1213608300.26255.665.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> Again with help from Jaswinder Singh.
> 
> Omitting the large part of the patch which actually moves the firmware
> around, since you'll need to pull from the git tree to get the preceding
> patches if you want to test it anyway.
> 
> We store the firmware in little-endian form now, and thus use
> __raw_writel() to write it to the device, to avoid byteswapping by
> writel(). I've revamped that loop in ace_copy() a little bit so it could
> probably do with being tested.
> 
> I've dropped the information about SBSS and BSS sections of the firmware
> -- we were clearing the whole of the device's memory in advance anyway,
> so clearing the BSS sections for a _second_ time seems pointless. And
> since the text,rodata,data sections were (almost) contiguous, we now
> just load those as a single blob rather than keeping them separate.
> 
> Although it probably isn't necessary, we do preserve the ability to
> change the load and start addresses from 0x4000, by putting them into a
> header at the beginning of the firmware blob, along with the version
> number.

Mostly ok...

1) firmware separation should be a separate patch from 
request_firmware() support addition

2) [minor] firmware Kconfig entries should default to 'Y' during 
transition, though it's ok to remove those after transition is over

3) there are enough changes to warrant a requirement of a "driver still 
works" test before going in, IMO

