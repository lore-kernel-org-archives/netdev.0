From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Tue, 6 Jun 2017 12:54:52 -0700
Message-ID: <20170606125452.7ea8de2d@cakuba.netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
        <20170606061610.GA1911@nanopsycho>
        <20170606002105.7a84432f@cakuba.netronome.com>
        <20170606082336.GB1911@nanopsycho>
        <20170606020945.05a9bcc5@cakuba.netronome.com>
        <20170606091757.GC1911@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:34683 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751239AbdFFTzD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 15:55:03 -0400
In-Reply-To: <20170606091757.GC1911@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jun 2017 11:17:57 +0200, Jiri Pirko wrote:
> >> >What were your plans with pre-netdev config?    
> >> 
> >> We need to pass come initial resource division. Generally the consensus
> >> is to have these options exposed through devlink, let the user configure
> >> them all and then to have a trigger that would cause driver
> >> re-orchestration according to the new values. The flow would look like
> >> this:
> >> 
> >> -driver loads with defaults, inits hw and instantiates netdevs
> >> -driver exposes config options via devlink
> >> -user sets up the options
> >> -user pushes the "go" trigger
> >> -upon the trigger command, devlink calls the driver re-init callback
> >> -driver shuts down the current instances, re-initializes hw,
> >>  re-instantiates the netdevs
> >> 
> >> Makes sense?  
> >
> >I like the idea of a "go"/apply/reload trigger and extending devlink.
> >Do you plan on adding a way to persist the settings?  I'm concerned NIC
> >users may want to boot into the right mode once it's set, without
> >reloads and reconfigs upon boot.  Also is there going to be a way to
> >query the pending/running config?  Sounds like we may want to expose
> >three value sets - persistent/default, running and pending/to be
> >applied.  
> 
> I don't think it is a good idea to introduce any kind of configuration
> persistency in HW. I believe that user is the master and he has all
> needed info. He can store it persistently, but it is up to him. 
> 
> So basicaly during boot, we need the devlink configuration to happen
> early on, before the netdevices get configured. udev? Not sure how
> exactly to do this. Have to ask around :)

Happy to hear that.  Now there is two of us, I'll try again with the
marketing dept :)
