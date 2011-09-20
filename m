From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Tue, 20 Sep 2011 14:59:18 -0400
Message-ID: <20110920185918.GX21309@gospo.rdu.redhat.com>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com> <1316477404.14749.256.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>,
	nhorman@tuxdriver.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab1ITS72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 14:59:28 -0400
Content-Disposition: inline
In-Reply-To: <1316477404.14749.256.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2011 at 01:10:01AM +0100, Ben Hutchings wrote:
> On Mon, 2011-09-19 at 16:42 -0700, Stephen Hemminger wrote:
> > I would like to see a general solution to allow configuring
> > napi weight. The Rx weight isn't easily configurable either.
> 
> Indeed.
> 
> > Probably needs to be through ethtool callback since actual value range
> > and dev -> napi relationship is device specific.
> 
> The maximum meaningful value is device specific but I'm not sure that
> really matters.
> 
> And as David said it's really a many-to-one mapping of queue -> NAPI.
> At netconf we talked about having 'irq' as an attribute of each queue
> but maybe we should expose NAPI contexts through sysfs and make queues
> refer to them instead.  NAPI contexts would be named (in the same way as
> the corresponding IRQ handlers) and have irq, weight, etc.
> 
> (Still short of time to work on this myself, alas.)
> 

I've been having a similar discussion with Neil Horman about how we can
better control all sorts of device values (interrupts, number of queues,
queue to node mapping, etc.).  Some of this is based on what I would
like to see and some is from Stephen's talk at LPC two weeks ago.  I
think the sysfs work Neil has done and posted to lkml can easily be
expanded to allow enhanced configuration of each device.  Having napi
weight in there too seems like a reasonable addition to this.
