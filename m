From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Thu, 03 Aug 2006 19:14:59 +1000
Message-ID: <44D1BE93.1080308@snapgear.com>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com> <20060803073307.GA29775@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:35747 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S932363AbWHCJPG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:15:06 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060803073307.GA29775@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> So now you _need_ bridging in the middle to send ethernet traffic over
> a GRE tunnel?  Ugh.

Agreed that would not be nice.  What is the usage scenario for this?
At least one end of the tunnel will be bridged?

> If you really want to send ethernet and non-ethernet traffic over the
> same tunnel, can't you make multiple devices?

Do you mean make multiple GRE devices, where one has an ethernet mode set?
That would require more extensive changes to GRE than my original patch.
I don't think being able to send both is important enough to justify that.
Better to just use my original patch if that is acceptable.  There are
parts of it I can clean up more, but nothing major.  And it still needs
some userspace modifications.

Or create a new virtual device to sit between gre and bridging that
simply adds the ethernet header?  This is the most modular approach,
but it seems like overkill for such a simple thing.

> If GRE generally transmits BPDUs without ethernet header, the handling
> for that ought to be in GRE, IMHO.

I don't think this is normal behaviour.  At least, not all routers do it.
More likely some routers have done it as an optimisation.  It does appear
to be specific to GRE.

