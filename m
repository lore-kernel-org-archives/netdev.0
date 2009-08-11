From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] be2net: Implementation of request_firmware interface.
Date: Tue, 11 Aug 2009 12:55:10 -0400
Message-ID: <20090811165510.GP8515@gospo.rdu.redhat.com>
References: <20090702111820.GA21085@serverengines.com> <1246566808.9821.2.camel@deadeye> <20090705121637.GA3627@serverengines.com> <1246803604.3898.6.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57224 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754678AbZHKQzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2009 12:55:13 -0400
Content-Disposition: inline
In-Reply-To: <1246803604.3898.6.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 03:20:04PM +0100, Ben Hutchings wrote:
> On Sun, 2009-07-05 at 17:46 +0530, Sarveshwar Bandi wrote:
> > I understand that most drivers  use request_firmware() to load  volatile
> > firmware. I do see that there are other nic drivers that use this inferface to
> > flash persistent firmware.
> > 
> >  We have other tools for offline flashing; but there is requirement
> > to flash f/w through driver without having to use other proprietary  tools.
> 
> The firmware blob is proprietary and has to be distributed separately
> from the kernel.  So does it really matter that you have to distribute a
> special tool as well?
> 

I guess I don't share the same opinion that the binary firmware is
required to be distributed separately since it is not that way today.
If we get rid of all files in firmware/ that do not have source
included, there will not be much left.

I applaud efforts by hardware vendors and others to submit patches that
allow drivers to update their own firmware at load-time if the on-card
version isn't compatible with the driver getting ready to load.  If one
does not want them updated, don't put the files in /lib/firmware.

Using a standard method (like using request_firmware) seems much more
logical than requiring users to download and compile some vendor
specific application to get new firmware.  It also means that if a
vendor is willing to drop a binary blob into firmware/ it's a pretty
easy thing to do.

> (Based on requirements specified by major OEMs, I have implemented
> firmware update through the sfc driver (MDIO and MTD interfaces) but
> under the control of a separate tool.)

And there are plenty of OEMs out there that complain loudly if it's not
easy to move quickly from one on-card/in-memory firmware to another when
changing driver versions.  Trust me, I hear from them.

