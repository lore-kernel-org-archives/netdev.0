From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: Ethernet low-level frame debugging support
Date: Mon, 20 Jun 2011 08:57:08 +0930
Message-ID: <20110620085708.45a09f21@opy.nosense.org>
References: <20110619104431.23a22fe9@opy.nosense.org>
	<4DFE59E0.9070503@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:41883 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab1FSX1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:27:12 -0400
In-Reply-To: <4DFE59E0.9070503@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Sun, 19 Jun 2011 13:19:44 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 06/18/2011 06:14 PM, Mark Smith wrote:
> > Hi,
> >
> > Firstly, I think this is a potentially quite useful feature for
> > networking people and that I hope it makes it into the kernel proper.
> >
> > One thing I've thought is that perhaps it might be made and named a bit
> > more generally, as NICs will also drop frames for other reasons other
> > than FCs failures e.g. runt frames. So perhaps something like "true
> > promiscuous" or "full promiscuous" might be a more general name, and if
> > it is enabled, then all NIC error checking that can be switched off is
> > switched off. Looking at the chipset data sheets for a few NICs that I
> > have / have had (netgear FA312 (natsemi ns83815), smc epic100, ne2000),
> > they all seem to have registers which allow switching off many if not
> > all of the NIC error checking settings.
> 
> I called it 'save-rxerr' in ethtool...I think that is general enough?
> 

Yes, I think so.

> The early patch that saves the FCS just passes the 4-byte FCS up the stack.
> It doesn't change the ability to receive bad frames or not..that is in the
> later patches.
> 
> >
> > The other thing I've thought could be useful would be to be able to
> > send runts by not padding the frames when they're less then 64 bytes.
> > I've been able to test if this is possible with the netgear FA312, as
> > the chipset does the padding. I connected it back to back with an
> > e1000e I have, switched off the chipset automatic padding on the FA312,
> > sent small traffic, and then saw that the e1000e's internal
> > rx_short_length_errors counter correspondingly increased. Of course I
> > can't see them with tcpdump on the e1000e because it is dropping them.
> 
> Maybe the SO_NOFCS option could change to SO_DRVOPTS and take a bit-field
> instead of just be on/off.  NOFCS could be one flag, NOPAD another, etc.

Separating them out as individual flags would probably be best in a
testing situation. Allowing for other flags, and perhaps even flags and
variables could be useful. One thing I've been a bit intrigued about is
that on the FA312 chipset, one of the registers allows you to change
the length of the inter frame gap. I'm not sure why you'd want to,
however it would appear to have been useful enough for national
semiconductor to put it into a production and commodity chipset. In my
browsing I remember also seeing registers to do things like change the
collision recovery algorithm or timing.

> That would give ability to send non-padded frames if the driver has
> support.
> 

I think there might be a possibility that all or a lot of them would
support sending frames that aren't padded. 

The goal of my test above was only really to see if a network card
would send a runt, with the FA312 being an easy one to test with,
because all I had to do is poke one of the registers to switch on and
off padding, rather than having to modify a driver and build and run up
a test kernel or driver, as I don't have a test/development environment
already setup.

For cards that don't do padding in hardware, perhaps it might be as
easy as making the skb_padto call conditional.

Regards,
Mark.




> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
