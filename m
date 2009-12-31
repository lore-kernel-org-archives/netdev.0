From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] ep93xx_eth.c: general cleanup
Date: Thu, 31 Dec 2009 10:11:22 +0100
Message-ID: <20091231091122.GP1735@mail.wantstofly.org>
References: <20091223.141458.193725880.davem@davemloft.net> <BD79186B4FD85F4B8E60E381CAEE19090200F635@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joe@perches.com
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:54308 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbZLaJLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 04:11:24 -0500
Content-Disposition: inline
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200F635@mi8nycmail19.Mi8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2009 at 01:03:00PM -0500, H Hartley Sweeten wrote:

> >> Wednesday, December 16, 2009 11:32 AM, Lennert Buytenhek wrote:
> >>> On Wed, Dec 16, 2009 at 01:18:13PM -0500, H Hartley Sweeten wrote:
> >>>
> >>>> V3 - Change pr_fmt() as suggested by Joe Perches
> >>>>      Don't remove DRV_MODULE_NAME and DRV_MODULE_VERSION
> >>>>      Don't remove the message in ep93xx_eth_init_module()
> >>>
> >>> That's not what I meant, but alright, as you prefer.
> >> 
> >> Guess my parser is off line today.... ;-)
> >> 
> >> What did you mean?
> >
> > This patch also doesn't apply to current sources, so if you
> > could also please respin this once you've resolved the feedback
> > that would be great.
> 
> Lennert,

Hi Hartley,


> Since I need to respin this patch what did you mean by this comment?
> 
> On Wednesday, December 16, 2009 11:09 AM, Lennert Buytenhek wrote:
> > On Wed, Dec 16, 2009 at 01:06:10PM -0500, H Hartley Sweeten wrote:
> >
> >>>> General cleanup of the ep93xx_eth driver.
> >>>
> >>> Apart from keeping DRV_MODULE_NAME and DRV_MODULE_VERSION, I have
> >>> no strong opinion about this one way or the other.  So I guess that
> >>> means ACK.
> >> 
> >> I will add back the DRV_MODULE_NAME and DRV_MODULE_VERSION and repost.
> >> 
> >> What about the message in ep93xx_eth_init_module()?  Would you prefer
> >> that one to stay?
> >
> > Most drivers I'm familiar with print a version message when they are
> > first instantiated -- perhaps that makes more sense.
> 
> I will wait for your reply before updating the patch.

What I meant was, most drivers seem to print a message at probe
time, i.e. when they are attached to an actual device for the first
time.

Grepping for 'printed_version' in drivers/net/* actually turns up
two variants:
- Print the version message on the first probe.  (e.g. 3c59x)
- Print the version message at module load time if we were built as
  a module, while if we were built into the kernel, only print a
  version message on the first probe.  (e.g. 8139too)

At least in the case of ep93xx_eth, you can't even have it enabled if
you're not building a kernel specifically for the ep93xx ARM SoC, and
if you are building for the ep93xx, as far as I know we don't support
any boards that don't have the ethernet brought out and so you're very
likely to have ep93xx_eth enabled then, so whether you do it
unconditionally at driver init time or at probe time will make no
effective difference for the majority of cases.

I.e. I can't really say I care much either way.


cheers,
Lennert
