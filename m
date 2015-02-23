From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: [PATCH 2/2] dsa: mv88e6131: support fixed PHYs
Date: Mon, 23 Feb 2015 12:13:28 +0100
Message-ID: <20150223111328.GA21602@gmail.com>
References: <20150212141317.GB12318@gmail.com>
 <CAGVrzcb5Vcx3fwFf3sVBGqw9QgZp9PD3TOZhO-CT5Eevzz5rzw@mail.gmail.com>
 <20150221103005.GA9212@gmail.com>
 <CAGVrzcb-di9Q9z8VohmSt7f0tq=BOxJ2=XXiRKRj1FToQo3=fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:45829 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbbBWLNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 06:13:39 -0500
Received: by lbjb6 with SMTP id b6so17571574lbj.12
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 03:13:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAGVrzcb-di9Q9z8VohmSt7f0tq=BOxJ2=XXiRKRj1FToQo3=fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2015 at 10:56:25AM -0800, Florian Fainelli wrote:
> 2015-02-21 2:30 GMT-08:00 Tobias Waldekranz <tobias@waldekranz.com>:
> > On Thu, Feb 12, 2015 at 08:13:28AM -0800, Florian Fainelli wrote:
> >> 2015-02-12 6:13 GMT-08:00 Tobias Waldekranz <tobias@waldekranz.com>:
> >> > Statically setup the PCS Control on the MAC to match the fixed PHY.
> >>
> >> bcm_sf2 supports both fixed PHYs and regular PHYs, yet we do not need
> >> to get access to the fixed PHY status from the adjust_link callback
> >> because you could implement a separate fixed_link_update callback for
> >> that purpose.
> >>
> >> Did not that work for you?
> >>
> >
> > That was my first approach and it worked fine. The only issue I saw
> > was that the callback was continously called at each poll cycle even
> > though the link state had not changed.
> 
> Right, we poll using this callback fairly often. Just like the PHY
> libraries adjust_link, drivers are responsible for implementing
> "caching" and avoiding the callback to be invoked too frequently.
> 
> >
> > So then I implemented the same check for updates that was in the
> > regular adjust_link callback. But before I submitted that version of
> > the patch I looked att the sf2 code, and it seemed as though this code
> > uses the callback to update the phy status based on the chip state and
> > not the other way around. Did I misunderstand the code?
> 
> It is a two step process:
> 
> - fixed_link_update updates the fixed PHY's status member to reflect
> the HW changes (link change mostly), updates the PHY device
> speed/duplex/pause parameters
> 
> - adjust_link reads the PHY device speed/duplex/pause and applies
> these to the HW registers

Right, in my case I just need to do an initial config according to the
fixed settings which are read from the device-tree.

In the case where there is a real PHY attached to the switch, an
internal machine will poll the PHY and setup the MAC accordingly. So
HW will take care of step 2 for me.

> >
> > Not wanting to break your code, I went with this approach instead. But
> > if you're fine with it, I'm more than happy to go with that version.
> 
> I think it is a little cleaner since the adjust_link callback does not
> need to know what kind of PHY device it is dealing with, while the
> fixed_link_update() one only takes care of fixed PHYs.

In my case I do need to know, since I want the switch's phy polling
unit to do the work when possible. Maybe I should just rethink the
whole thing and do the setup at probe-time using some other method.

I will get back to you with a better solution :)

> Thanks
> -- 
> Florian

-- 
Thanks
 - wkz
