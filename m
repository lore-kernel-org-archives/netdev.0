From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 14:52:11 +0200
Message-ID: <1208177531.2572.26.camel@lov.site>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <3ae72650804140503g73f8c281w438defb1c6477ba9@mail.gmail.com>
	 <1208175549.31695.67.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco d'Itri <md@linux.it>, Harald Hoyer <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:62687 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267AbYDNMwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 08:52:32 -0400
In-Reply-To: <1208175549.31695.67.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-14 at 13:19 +0100, David Woodhouse wrote:
> On Mon, 2008-04-14 at 14:03 +0200, Kay Sievers wrote:
> > 
> > >  One thing I don't understand: Don't we already emit a KERNEL== criterion
> > >  in the case where there is already a udev rule 'reserving' the name that
> > >  the kernel used for the current device? Why is that one OK, and why only
> > >  in that case? This patch just makes it consistent.
> > 
> > Yes, we do that in the recent udev versions. We only make sure we keep
> > the enumeration across the same basename, not across different device
> > names.
> 
> Right, but you _only_ do that when you're asked to create a rule for a
> device where the kernel's name matches a pre-existing rule.

We do it for all new rules, regardless of pre-existing rules with that
name. It just does not add KERNEL, if some external tool tried to
overwrite the kernel name, we write a rule for.

Not sure why Fedora rules are mangling INTERFACE_NAME here:
  https://bugzilla.redhat.com/show_bug.cgi?id=440568#c4

> You don't do it consistently --

Right, we will do that, if there are no other issues coming up with the
general approach of adding KERNEL matches.

> and Marco was objecting to a patch which just made it
> happen consistently.

Right, I'm just waiting for Marco to comment on this.

> That patch on its own would be sufficient to fix the PS3 and Libertas
> problems, since the kernel uses a different basename for the logical
> devices we want to disambiguate. (It would also fix the clash between
> wlan0 and wmaster0 on mac80211 interfaces).

Sure, that's why we have it in every default rule.

> We probably also want to do the dev_id thing, but maybe not for PS3 and
> Libertas (since it affects their IPv6 addressing too).

It can just be in all rules, like the ATTR{type} match, right?

Thanks,
Kay

