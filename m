From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 14 Jun 2006 16:25:04 -0600
Message-ID: <20060614222504.GA13212@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org> <449068C9.1010304@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:53395 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S964772AbWFNWZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 18:25:07 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <449068C9.1010304@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 03:51:37PM -0400, Jeff Garzik wrote:
> You need to turn off the thing that generates work (DMA engine), before 
> turning off the thing that reaps work (irq handler).
...
> It should be completely obvious that the chip is still generating 
> work...

Yes, I agree it still generates work. ie we can still RX packets.
But those will get discarded anyway.
In other words, If work is generated and I don't know it and
don't care, was it really work? :)

>   You don't want to leave the hardware in a position where it has 
> unacknowledged events.

Ok. Let me repeat two questions I asked a while ago:
| Are you worried about a masked, pending interrupt causing
| problems when the driver is re-opened or resumed?

The answer to "Yes" it seems.
And we will disagree on that since I've proven it's not a problem.
And it can't be a problem anyone else has seen since it's been
this way for 5+ years.

| If firmware left the device in that state at boot time wouldn't
| the driver be required to handle it?

Can you comment on this please?

thanks,
grant
