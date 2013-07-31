From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 21:22:29 +0200
Message-ID: <20130731192229.GB8027@netboy>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-omap@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:33655 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab3GaTWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 15:22:42 -0400
Content-Disposition: inline
In-Reply-To: <20130731184525.GA629@radagast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 09:45:25PM +0300, Felipe Balbi wrote:
> On Wed, Jul 31, 2013 at 06:38:46PM +0200, Richard Cochran wrote:
> > On Wed, Jul 31, 2013 at 06:28:27PM +0300, Felipe Balbi wrote:
> > > On Wed, Jul 31, 2013 at 04:49:59PM +0200, Richard Cochran wrote:
> > > > On Wed, Jul 31, 2013 at 05:42:26PM +0530, Mugunthan V N wrote:
> > > > > The new IP version has a minor changes and the offsets are same as the previous
> > > > > version, so instead of adding CPSW version number in the driver, make the driver
> > > > > to fall through to the latest versions so that the new version of CPSW which has
> > > > > the same register offsets will work directly without patching the driver.
> > > > 
> > > > This doesn't make any sense to me. Why not just add the new version
> > > > number?
> > > > 
> > > > None of the hunks in your patch are on performance sensitive paths, so
> > > > I really can't see any point in removing the error checking.
> > > 
> > > well, if a new revision of the IP comes, the driver at least has some
> > > chance to work without having to be modified. If it turns out that there
> > > are really different features, then we patch a new version, otherwise we
> > > should just assume highest known version and try it out.
> > 
> > And if the driver reads junk from some random address due to
> > bootloader/DT/multikernel madness, it will happily peek and poke
> > around instead of rejecting the wrong version number.
> 
> that'd be a bug in the DT anyway, why should the driver have to cope
> with broken data ?

Um, it is called error checking?

Besides, by not checking the version number, you are pre-programming a
disaster that will occur when an older kernel is booted on the first
new IP version with important changes. Can you really be sure that all
users will have the new, patched kernel?

Thanks,
Richard
