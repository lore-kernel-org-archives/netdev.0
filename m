From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Use of ENOTSUPP in drivers?
Date: Sun, 12 Jan 2014 20:47:02 +0000
Message-ID: <1389559622.3720.115.camel@deadeye.wl.decadent.org.uk>
References: <20140112185715.GB5405@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31309 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaALUrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 15:47:06 -0500
In-Reply-To: <20140112185715.GB5405@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 19:57 +0100, Sabrina Dubroca wrote:
> Thu, 2 Jan 2014 12:01:31 +0000, Ben Hutchings wrote:
> > Never return error code ENOTSUPP; it's *not* the same thing as ENOTSUP
> > in userland and is not part of the userland ABI.  I would use EINVAL
> > here.
> 
> 
> I've found a few ethernet drivers that return -ENOTSUPP in various
> functions. In particular, some ethtool functions or ioctl's.
> Ben's message makes me think that the ethtool functions and ioctl's
> should be modified.
> 
> There are other occurences, mostly in functions related to device
> initialization. I didn't manage to track down exactly from where some
> of them are called, and I don't know if ENOTSUPP is okay in these.
> 
> I've included the complete list of occurences (based on net-next) from
> drivers/net/ethernet in patch form at the end, if that's more
> convenient than the file/function list. This is not meant to be
> applied.
> 
> 
> Do these (or part of them) need to be patched? Or is there something
> I'm missing?
[...]

I believe they should all be patched.  According to
include/linux/errno.h, ENOTSUPP is meant for use in the NFSv3 code only.
(But it's apparently erroneously used *all over* the tree, not just in
net drivers!)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
