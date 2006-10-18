From: Pavel Roskin <proski@gnu.org>
Subject: Re: [Madwifi-devel] d80211: ANNOUNCE: DadWifi, a port of
	MadWifi	to d80211
Date: Wed, 18 Oct 2006 02:20:27 -0400
Message-ID: <1161152427.3922.23.camel@portland>
References: <20061018001403.GA22990@devicescape.com>
	 <20061017185116.1f14bd86@dads-laptop> <1161145560.2285.32.camel@portland>
	 <20061017215532.3d3c769a@dads-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:48517 "EHLO c60.cesmail.net")
	by vger.kernel.org with ESMTP id S1751081AbWJRGUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 02:20:37 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061017215532.3d3c769a@dads-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-17 at 21:55 -0700, Stephen Hemminger wrote:
> > On Tue, 2006-10-17 at 18:51 -0700, Stephen Hemminger wrote:
> > > I would consider this a BAD thing. You are creating a derived work
> > > out of GPL and non-GPL software. This actually will hurt the possible acceptance
> > > of the d80211 stack into the mainline kernel.
> > 
> > On the contrary, I think this effort with spur interest in d80211,
> > Atheros hardware and stimulate development of OpenHAL.  It will also put
> > additional pressure on Atheros to open HAL sources.
> 
> HAL's are bad as well. You want a real driver, not one that has multiple
> layers of indirection.

I think "dissolving" HAL once its open is much easier than porting the
driver from one 802.11 stack to another.  The former is just a matter of
moving functions around, making some of them inline, renaming constants,
fixing some ugly code.  It's a set of simple operations, each of which
keeps the driver functional.  If anything breaks, it's easy to track
back to the minor change that broke it.

Porting to another 802.11 stack is a quantum leap that can only be done
in one step and that could break lots of things at once.  It could also
reveal limitations of the new stack that need to be fixed.  It's so
commendable that somebody is trying to do the hardest part.

> > The technical ability of d80211 to handle a popular chipset would hardly
> > undermine its chances to be included into the kernel.  It takes more
> > that one step to achieve free in-kernel support for Atheros chipsets.
> > DadWifi may be one of those steps, OpenHAL or open-sourcing the Atheros
> > HAL would be the other.
> 
> If Atheros does open source their existing driver. Someone will need to
> do a new driver that gets rid of the HAL layer.

Yes, but this can be evolutionary.  Some code from HAL could actually
migrate into the kernel or to a userspace utility.  We still want
country-specific limitations, at least by default, so that users don't
break local regulations unknowingly.

And even if the complete rewrite is needed, d80211 will be prepared to
deal with Atheros cards, because the responsibilities of the firmware
and the host software won't change.

> > Should d80211 be merged with the existing 802.11 stack in the kernel,
> > users of DadWifi would be among the testers, and they will ensure that
> > useful features of d80211 are not lost.
> 
> As a test or transition vehicle it is a DadWifi is good, but hopefully it
> won't slow the progress to a real open source solution

I think it may speed things up.  Once the kernel integration is in
sight, OpenHAL developers would have a stronger motivation to produce a
working and copyright-clean product.

> > Unless I'm missing something obvious, I don't see absolutely anything
> > that could harm the chances of d80211 to make it to the mainline
> > kernel.
> 
> Christoph et. all will insist that everything be EXPORT_SYMBOL_GPL.

That shouldn't be an issue at all.  HAL does not and can not call any
Linux functions directly.  It can only communicate to the kernel through
a wrapper that will be under GPL.  Note that it's not circumvention of
EXPORT_SYMBOL_GPL.  It's a direct consequence of the fact that HAL is
indeed not derived from Linux.

-- 
Regards,
Pavel Roskin
