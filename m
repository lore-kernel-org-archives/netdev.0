From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next 0/9] Introduce devlink interface and first
 drivers to use it
Date: Tue, 23 Feb 2016 11:19:37 -0500
Message-ID: <20160223161936.GT33942@gospo.home.greyhouse.net>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <20160223051214.GP33942@gospo.home.greyhouse.net>
 <20160223073203.GA2140@nanopsycho.orion>
 <20160223143418.GQ33942@gospo.home.greyhouse.net>
 <20160223144550.GG2140@nanopsycho.orion>
 <20160223155527.GS33942@gospo.home.greyhouse.net>
 <20160223160131.GL2140@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:36376 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbcBWQTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 11:19:41 -0500
Received: by mail-yw0-f174.google.com with SMTP id e63so150051212ywc.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 08:19:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223160131.GL2140@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 05:01:31PM +0100, Jiri Pirko wrote:
> Tue, Feb 23, 2016 at 04:55:28PM CET, gospo@cumulusnetworks.com wrote:
> >On Tue, Feb 23, 2016 at 03:45:51PM +0100, Jiri Pirko wrote:
> >> Tue, Feb 23, 2016 at 03:34:19PM CET, gospo@cumulusnetworks.com wrote:
> >> 
> >> <snip>
> >> >> 
> >> >> >> 	myhost:~$ dl port show
> >> >> >> 	devlink0/1: type eth netdev ens4
> >> >> >                             ^^^^^^^^^^^
> >> >> >> 	devlink0/2: type ib ibdev mlx4_0
> >> >> >                            ^^^^^^^^^^^^
> >> >> >I think my only other question about this implementation is whether or
> >> >> >not one would really want to have the true netdev/ibdev names mapped
> >> >> >here.
> >> >> >
> >> >> >Would be as reasonable to simply specify the type (and there may be more
> >> >> >types within ethernet that could be useful in multi-chip configurations)
> >> >> >and then let normal infrastructure that exists today figure out how to
> >> >> >map the names for the netdevs to the devices?
> >> >> 
> >> >> What normal infrastructure you have in mind? There is no info about
> >> >> devlink port mapping to netdev/ibdev anywhere. Only here. I might be
> >> >> missing something but I fail to see what's wrong with it.
> >> >
> >> >I was simply wondering out loud if we _really_ wanted to name netdevs
> >> >this way.  I was suggesting that output could be like this:
> >> >
> >> >myhost:~$ dl port show
> >> >devlink0/1: type eth
> >> >devlink0/2: type ib 
> >> >
> >> >mnd that udev/systemd/biosdevname/etc would take care of naming the
> >> >device whataever it wanted.  This appears to be essentially the same
> >> >concern Hannes has.
> >> 
> >> Wait. The only thing which will be renamed by udev is "devlink0". The
> >> suffixes "/1" and "/2" are direct indexes as used inside the driver.
> >> 
> >> And you need some link to netdev in case netdev exists - therefore
> >> "netdev ens4" attribute is there. There's no other way to get the
> >> mapping of "devlink0/1" to "ens4" anywhere else.
> >
> >So I think I had invisioned a slightly different workflow than what you
> >just described.
> >
> >- Load PCI driver
> >- Setup devlink attributes for your hardware
> >- Create netdevs in network driver based on those attributes
> >
> >You don't need a netdev to reference any of the devlink specific
> >parameters do you?
> 
> No, I have a devlink handle and a devlink port index. That is enough.

That's what I read as well and why I wondered why you said this:

> >> And you need some link to netdev in case netdev exists - therefore
> >> "netdev ens4" attribute is there. There's no other way to get the
> >> mapping of "devlink0/1" to "ens4" anywhere else.

It just doesn't seem like referencing the netdev when performing set
operations was needed.

I see no issue having it appear a dump action after the fact, but
it seems like devlink[unit number]/[port number] would be enough to
reference the proper hardware mapping.  
