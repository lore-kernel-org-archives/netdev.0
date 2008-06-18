From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Wed, 18 Jun 2008 17:14:41 +0100
Message-ID: <1213805681.26255.1312.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <4856CE43.4020706@garzik.org>
	 <1213652749.26255.842.camel@pmac.infradead.org>
	 <4856E50C.5050908@garzik.org>
	 <1213699220.26255.977.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34124 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbYFRQOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:14:50 -0400
In-Reply-To: <1213699220.26255.977.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-17 at 11:40 +0100, David Woodhouse wrote:
> 
> > IOW, the first step for each driver should be:
> > 
> > +     request_firmware()
> > +     if (success)
> > +             use externally-loaded firmware
> > +     else
> >               use built-in firmware
> > 
> > and that's it.  Nothing else [in the first patch].
> 
> If it were that simple, I would agree with you. In practice, it hasn't
> turned out to be that simple. I really do think it would be
> counter-productive for both review and testing purposes. 
> 
> For review because, as I said, we'd end up providing new copies of
> certain functions in the first patch (or conditional noise in them), and
> then ripping out the old code path in the second -- the patch which it
> would make sense to _read_ and review would be the combined one.
> 
> For testing because there's quite a large chance that if something goes
> wrong with the request_firmware() path, it'd fall back to the other path
> and people would say "OK, that works" when it doesn't. And we both know
> that kind of thing will still happen even if we have a bloody great
> warning printk in the fallback case.
> 
> I suppose what we _could_ do is make your 'use built-in firmware' path
> use that firmware in the _same_ form as we have it provided by
> request_firmware(). That way, we really are testing the same code path.
> Would that meet your approval?
> 
> If you look closely, you'll see that that is exactly what I've done
> already. But without the complexity in the driver -- the driver just
> calls request_firmware(), and the firmware is either provided from
> within the kernel image, or from userspace.

I believe you didn't respond to this, but just spouted the same
complaint at another patch which was posted for review, without even
seeming to have _looked_ at the part of that patch which really needed
reviewing.

This has needed doing for a long time, and I've finally got off my
posterior and started working on it. If you wanted it done precisely
your way, you could always have done it yourself. As it is, we have a
minor disagreement about some of the details, but it still needs doing.
And since it still seems to be me doing it and not you, I'm still doing
it the way I believe is best.

We have a bunch of other drivers to fix up to use request_firmware(),
other than the network drivers. If you like, we can move on to those and
let you do drivers/net your way, splitting each patch into two stages.
I think it's pointless and counter-productive to do it that way, but if
it's your own time you're wasting on generating that extra churn, then I
suppose it's not _so_ counter-productive that I would argue that we
should reject your patches. People can always run 'combinediff' on your
two patches to get a single, reviewable patch which would match the one
we would have sent, after all. And the harm to the testing process is
your concern, once you're providing the patches :)

OK?

-- 
dwmw2

