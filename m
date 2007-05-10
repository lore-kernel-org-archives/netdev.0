From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Thu, 10 May 2007 09:00:10 -0700
Message-ID: <20070510090010.4c6b8589@freepuppy>
References: <20070430142349.79754c1b@freekitty>
	<46374784.7010401@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org, Francois SIMOND <curio@free.fr>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36328 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758851AbXEJQC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 12:02:28 -0400
In-Reply-To: <46374784.7010401@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 01 May 2007 09:58:28 -0400
Daniel Drake <dsd@gentoo.org> wrote:

> Hi Stephen,
> 
> Stephen Hemminger wrote:
> > This fixes the regression in 2.6.21 for users with 88e8056 on motherboard.
> > Allow all but the Gigabyte motherboard has some unresolved bus problems.
> 
> > +	/* Some Gigabyte motherboards have 88e8056 but cause problems
> > +	 * There is some unresolved hardware related problem that causes
> > +	 * descriptor errors and receive data corruption.
> > +	 */
> > +	if (pdev->vendor == PCI_VENDOR_ID_MARVELL &&
> > +	    pdev->device == 0x4364 && pdev->subsystem_vendor == 0x1458) {
> > +		dev_err(&pdev->dev,
> > +			"88E8056 on Gigabyte motherboards not supported\n");
> 
> Gentoo have reports of sky2 working fine on Gigabyte boards which have 
> 88E8056 devices:
> https://bugs.gentoo.org/show_bug.cgi?id=176219
> 
> Can the patch be refined further?

I can use DMI to narrow down to one motherboard. 
Or just let everything through and let user's discover what's unstable, it fails
relatively quickly.

Could you please get full PCI info lspci -vvxxx for working/non-working 88e8056 (Yukon EC-U)
systems? It might be some PCI Express setup by the BIOS, but so far haven't
found any difference that mattered.

Have tried newer BIOS and qualified memory as obvious first steps.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
