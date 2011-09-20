From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Tue, 20 Sep 2011 16:23:05 -0400
Message-ID: <20110920202305.GC16323@hmsreliant.think-freely.org>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
 <1316477404.14749.256.camel@deadeye>
 <20110920185918.GX21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37955 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab1ITUXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 16:23:19 -0400
Content-Disposition: inline
In-Reply-To: <20110920185918.GX21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2011 at 02:59:18PM -0400, Andy Gospodarek wrote:
> On Tue, Sep 20, 2011 at 01:10:01AM +0100, Ben Hutchings wrote:
> > On Mon, 2011-09-19 at 16:42 -0700, Stephen Hemminger wrote:
> > > I would like to see a general solution to allow configuring
> > > napi weight. The Rx weight isn't easily configurable either.
> > 
> > Indeed.
> > 
> > > Probably needs to be through ethtool callback since actual value range
> > > and dev -> napi relationship is device specific.
> > 
> > The maximum meaningful value is device specific but I'm not sure that
> > really matters.
> > 
> > And as David said it's really a many-to-one mapping of queue -> NAPI.
> > At netconf we talked about having 'irq' as an attribute of each queue
> > but maybe we should expose NAPI contexts through sysfs and make queues
> > refer to them instead.  NAPI contexts would be named (in the same way as
> > the corresponding IRQ handlers) and have irq, weight, etc.
> > 
> > (Still short of time to work on this myself, alas.)
> > 
> 
> I've been having a similar discussion with Neil Horman about how we can
> better control all sorts of device values (interrupts, number of queues,
> queue to node mapping, etc.).  Some of this is based on what I would
> like to see and some is from Stephen's talk at LPC two weeks ago.  I
> think the sysfs work Neil has done and posted to lkml can easily be
> expanded to allow enhanced configuration of each device.  Having napi
> weight in there too seems like a reasonable addition to this.
> 
> 


This is the work Andy is referring to for those interested:
http://marc.info/?l=linux-kernel&m=131644727521409&w=2

This version has Gregs Ack, and is waiting for an Ack from Jesse Barnes at the
moment.  I think Andy's probably right, theres room here for expansion to create
a relationship between a given interrupt and a napi wieght.  I expect what would
be most direct would be adding a napi_weight attribute that was conditional on
the class of the pci device allocating the irqs (make it visible for class 0x200
devs, invisible for others).

Thoughts?
Neil
