From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 15:40:04 +0100
Message-ID: <20090227144004.GC17040@xi.wantstofly.org>
References: <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com> <49A7DFC0.9050601@mlbassoc.com> <20090227125305.GW17040@xi.wantstofly.org> <49A7E87D.5090203@mlbassoc.com> <20090227132319.GY17040@xi.wantstofly.org> <49A7EA3D.8070800@mlbassoc.com> <20090227142754.GB17040@xi.wantstofly.org> <49A7FA57.7030504@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53432 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbZB0OkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 09:40:07 -0500
Content-Disposition: inline
In-Reply-To: <49A7FA57.7030504@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 07:36:07AM -0700, Gary Thomas wrote:

> >>>>> Also, can you show me what you're filling the dsa platform data
> >>>>> structure with?
> >>>> struct dsa_platform_data _switch_data = {
> >>>>     .port_names[0]  = "lan1.1",
> >>>>     .port_names[1]  = "lan1.2",
> >>>>     .port_names[2]  = "lan1.3",
> >>>>     .port_names[3]  = "lan1.4",
> >>>>     .port_names[4]  = "lan1.5",
> >>>>     .port_names[5]  = "lan1.6",
> >>>>     .port_names[6]  = "lan1.7",
> >>>>     .port_names[7]  = "lan1.8",
> >>>>     .port_names[10]  = "cpu",
> >>>>     .sw_addr = 1,
> >>>> };
> >>> Just this should do the trick.  So what's not working -- are the
> >>> interfaces not showing up?  Or packet RX/TX isn't working?  Or
> >>> something else?
> >> It won't let me bring up eth0 (my scripts try to run DHCP):
> >>   starting network interfaces...
> >>   24520:01 not found
> >>   eth0: Could not attach to PHY
> >>   ip: SIOCSIFFLAGS: No such device
> >>
> >> As for the other devices, they do show up if I let eth0 try to
> >> attach to the PHY:
> > 
> > OK.  If you try to cheat the gianfar driver by having it attach to
> > the PHY for lan1.1, and plug a network cable into lan1.1 so that the
> > link goes up and gianfar thinks that the link on eth0 is up, does that
> > enable you to pass packets over any of the switch interfaces?  That
> > should be working now in this stage.
> 
> So, what name do I use when the gianfar is trying to attach?
> It makes this call:
>   phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
> where phy_id="24520:01".
> 
> Using "24520:01:00" gets an error:
>   eth0: 24520:01:00 already attached
> 
> Maybe the DSA layer/driver needs to export a device "24520:01"
> which pretends all of the things that the gianfar wants (1000Mb/Full/Link)?

Well, this isn't DSA-specific -- e.g. if you'd hook your CPU's
ethernet MAC up to an FPGA, you'd be in the same situation.

Maybe there is some fake PHY you can instantiate -- the "Fixed"
MDIO bus maybe?  Can you try enabling CONFIG_FIXED_PHY and pointing
it to that?
