From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 13:19:09 +0100
Message-ID: <1208175549.31695.67.camel@pmac.infradead.org>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <3ae72650804140503g73f8c281w438defb1c6477ba9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco d'Itri <md@linux.it>, Harald Hoyer <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36609 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbYDNMTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 08:19:32 -0400
In-Reply-To: <3ae72650804140503g73f8c281w438defb1c6477ba9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-14 at 14:03 +0200, Kay Sievers wrote:
> 
> >  One thing I don't understand: Don't we already emit a KERNEL== criterion
> >  in the case where there is already a udev rule 'reserving' the name that
> >  the kernel used for the current device? Why is that one OK, and why only
> >  in that case? This patch just makes it consistent.
> 
> Yes, we do that in the recent udev versions. We only make sure we keep
> the enumeration across the same basename, not across different device
> names.

Right, but you _only_ do that when you're asked to create a rule for a
device where the kernel's name matches a pre-existing rule. You don't do
it consistently -- and Marco was objecting to a patch which just made it
happen consistently.

That patch on its own would be sufficient to fix the PS3 and Libertas
problems, since the kernel uses a different basename for the logical
devices we want to disambiguate. (It would also fix the clash between
wlan0 and wmaster0 on mac80211 interfaces).

We probably also want to do the dev_id thing, but maybe not for PS3 and
Libertas (since it affects their IPv6 addressing too).

-- 
dwmw2

