From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] ptp: dynamic allocation of PHC char devices
Date: Thu, 11 Apr 2013 11:52:01 +0200
Message-ID: <20130411115201.2471a94f@griffin>
References: <4a1dcbcfb28ea2d18b09561a370efe7a4b0a2c5f.1365590805.git.jbenc@redhat.com>
	<1365615436.2581.15.camel@bwh-desktop.uk.solarflarecom.com>
	<20130410.134927.1751916446892581975.davem@davemloft.net>
	<1365617559.2581.25.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<richardcochran@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736Ab3DKJwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 05:52:09 -0400
In-Reply-To: <1365617559.2581.25.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Apr 2013 19:12:39 +0100, Ben Hutchings wrote:
> On Wed, 2013-04-10 at 13:49 -0400, David Miller wrote:
> > Can't multiple (unrelated) devices carve out minor space in the same
> > major?  Isn't that why it's designed this way?
> 
> Only at a level above the core char device functions, e.g.
> misc_register() for singleton devices.  Unless I'm very much mistaken,
> when you allocate a char device range and specify major=0 you get a
> dynamically allocated and previously unused major, regardless of how
> many minors you asked for.

You're correct. And thinking about it, I indeed see no reason not to
allocate the full range. We save some memory that way, as each minor
range allocation is tracked by register_chrdev_region, and the code is
going to be simpler.

I'll respin the patch.

Thanks,

 Jiri
