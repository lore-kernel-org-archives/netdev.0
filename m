From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Mon, 16 Jun 2008 22:45:48 +0100
Message-ID: <1213652749.26255.842.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <4856CE43.4020706@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34426 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978AbYFPVpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:45:53 -0400
In-Reply-To: <4856CE43.4020706@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-16 at 16:34 -0400, Jeff Garzik wrote:
> Mostly ok...
> 
> 1) firmware separation should be a separate patch from 
> request_firmware() support addition

It's kind of hard to do that. Taking this patch as an example -- we've
had to make minor changes to the firmware loading w.r.t. endianness,
etc.

If we really wanted to do it in two steps of '1. add request_firmware()'
followed by '2. remove old static firmware', then the whole process
would just be a lot more cumbersome than we need.

In this case, the first patch would probably add a completely new
version of ace_load_firmware() and ace_copy(), while the second patch
would remove the old versions of each function. To make sense of and
review that lot, you'd actually want to run 'combinediff' on them anyway
so you end up with what I've posted here. Only then is it really obvious
what's happening.

I do understand the desire to keep patches simple and do things in
stages -- but in this case (and the other request_firmware() patches
I've done), it seems like separating those two steps would actually be
counter-productive.

AFAICT it doesn't make it any easier to test the new code path, either.
It's still only really testable after you've applied both patches,
surely?

> 2) [minor] firmware Kconfig entries should default to 'Y' during 
> transition, though it's ok to remove those after transition is over

I don't think it's good to have a 'default y' on options for which the
help text says "Say 'N' and let udev load it as $DEITY intended".

As a compromise, perhaps we could do a 'CONFIG_INCLUDE_ALL_FIRMWARE' and
make them all default to whatever that option is set to? I'm really
unconvinced of the need for that, though -- running 'make
firmware_install' is all that's necessary, and is the preferred option. 

> 3) there are enough changes to warrant a requirement of a "driver still 
> works" test before going in, IMO

Most definitely. As I said, I've been very careful to ensure that the
converted firmware is correct, in conjunction with the driver changes
(like the endianness considerations in this case). But that is no
substitute for testing.

-- 
dwmw2

