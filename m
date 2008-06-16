From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Mon, 16 Jun 2008 18:23:10 +0100
Message-ID: <1213636990.26255.822.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <18518.37862.812419.353804@jaguar.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jaswinder@infradead.org
To: Jes Sorensen <jes@trained-monkey.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33556 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976AbYFPRXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:23:13 -0400
In-Reply-To: <18518.37862.812419.353804@jaguar.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-16 at 12:25 -0400, Jes Sorensen wrote:
> Mmmmm,
> 
> I am not particular bothered as to whether or not to put the firmware to
> userspace or not, however has this patch been tested on big endian
> systems? Given that the card is big endian, how is this going to affect
> big endian systems?

We don't have hardware, so haven't been able to test it on either
little-endian or big-endian machines, but we took care to ensure that it
should work on both.

> Honestly, I think it's a bad idea to start messing with the byte order
> of the data for something that happens once at boot time.

Currently, we have the firmware in the host's native endianness -- it's
in the driver in an array of uint32_t. And we just call writel() with
each word of it in turn.

If we provide the firmware via request_firmware(), we don't want to have
separate versions of the firmware files for big-endian and little-endian
hosts. It makes much more sense just to have _one_ version of each
binary file, and either call writel(le32_to_cpu()) for each word, or
writel(be32_to_cpu()).

We chose the former, because it can be simplified to __raw_writel().

Since the CPU on the device is big-endian, I would be amenable to an
argument that we should store the firmware in its native big-endian
form, and load it with writel(be32_to_cpu()) instead.

It doesn't matter much either way, really. 

-- 
dwmw2

