From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Sun, 27 Oct 2013 13:19:02 -0400
Message-ID: <526D4B06.8040505@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:64733 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971Ab3J0RTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 13:19:06 -0400
Received: by mail-ie0-f175.google.com with SMTP id aq17so9466817iec.6
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 10:19:05 -0700 (PDT)
In-Reply-To: <526A6BB3.7050507@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/13 09:01, Felix Fietkau wrote:
> On 2013-10-25 1:43 PM, Jamal Hadi Salim wrote:

> I think it's common for the switch to have a global MAC address, not a
> per-port one.

Ok, I see. Real cheep.

> 'won't pass up the tag'? The switch is treated in pretty much the same
> way as a normal managed standalone switch (you know, one you can buy in
> a shop and plug your Ethernet cable into).
> You simply tell it, which VLANs to put on which ports, and make the
> ports tagged or untagged.
> The link between the switch and the CPU is not really special, for the
> switch it's just another port. This way of configuring works with pretty
> much all switches that we're using.

So does it get its own MAC address? Other than flooding broadcasts,
how does one end up sending packets to the cpu?

> Yes, some switches have them, and they can be useful when dealing with
> multiple VLANs.

Very nice. So we go from one extreme of cheep to sophisticated ;->
I think the only way you can achieve multiple tables on the bridge
is by creating multiple bridges.

> No, because the connection between the CPU and the switch is handled by
> a normal Ethernet MAC. The Ethernet chip doesn't care if there's a
> switch connected to it, or a regular PHY.
> It's just a normal MII connection, nothing more.
>
[..]
 >
 > Right, the netdev that owns the PHY is a normal Ethernet MAC, running
 > any normal Linux Ethernet driver.
 >
[..]
> I remain absolutely unconvinced that this will make the end result
> better. Right now, these switches act like separate devices, because
> aside from the fact that they're put on the same board with other
> components, they pretty much *are* separate devices.
>
> You seem to insist on treating it as a kind of port multiplexer + bridge
> accelerator instead of a mostly standalone switch.
>


Yes, the above is the point i was making.
I apologize for sounding like a broken record, but to just re-iterate:
there are, if i recall correctly, several drivers  in the kernel
which are challenged as such (with single entry point into the CPU)
which expose multiple netdevs with the driver acting as mux point.

> This may work for some devices, but on others this simply a model that
> the hardware wasn't designed for.

I agree. But what i just described above is not new. A lot of embedded
multiport NICs tend to be handicapped in exactly the same way.

> Sure, we could try to cram in all
> those special cases, extra options, and hack through the layers where
> they're in the way. If *all* you care about is being able to reuse the
> existing interfaces, that might even seem like a good idea.
>

I do care a lot about using existing interfaces ;-> Great usability
for someone to run a tool that has been around for 20 years and it
works. If i can just reuse my scripts without having to invent
new ones etc etc.

> On the other hand, I've pointed out quite a few examples where the model
> of trying to cram it into the bridge API is just a bad fit in general.
>

Sorry Felix, nothing you described is insurmountable.
The challenge here is non-technical:
You already have code that has been proven and is deployed for what 
appears to be sometime now.
I totally empathize.

cheers,
jamal
