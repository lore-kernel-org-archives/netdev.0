From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Wed, 26 Mar 2014 19:29:43 +0100
Message-ID: <20140326182943.GH22086@order.stressinduktion.org>
References: <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33261 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaCZS3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 14:29:45 -0400
Content-Disposition: inline
In-Reply-To: <20140326181436.GL2869@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 07:14:36PM +0100, Jiri Pirko wrote:
> >You are right, sw1p0 and sw1p1 were meant to be, say LAN ports in my example.
> >
> >I think there is an implicit convention that sw1 represents the
> >Ethernet switch port connected to the CPU Ethernet MAC, and that it is
> >always connected, hence there is no need to create a "fake" bridge to
> >link sw1 to eth0 for instance?
> 
> I think you are kind of mixing apples and oranges (or I might be I'm not
> understanding you correctly).

I guess the discussion is only about user interface:

In case someone adds a bond on switch ports without knowing the details
of the kernel and interfaces, the kernel would transparently setup this
configuration on the switch via the specific driver. iproute bond interface
stays the same but backend differs.

Actually, I find the idea pretty neat, but the bonding netlink/sysfs
interface would be required to expose feature information, because
maybe not every switch supports each (bonding) feature (like l4-hashing)
and software fallback maybe not possible.

> This is how I see it, sticking to the names you use in the example:
> 
>             (sw1) (abstract place-holder netdev)
>           --------
>          switch chip                   CPU
>    -----------------------            ------
>    sw1p0 sw1p1 sw1p2 sw1p3             eth0
>      |     |     |     |                |
>     PHY   PHY   PHY    ------someMII-----
> 
> You see that eth0 is the CPU part of the "connection" and sw1p3 is the
> switch part (port representation). 
>
> >>>ip link add link eth0 name eth0.2 type vlan id 2
> >>>
> >>>ip link add link sw1p0 name sw1p0.1 type vlan id 1
> >>>ip link add link sw1p1 name sw1p1.1 type vlan id 1
> >>>
> >>>ip link add sw1.1 type bridge
> >>>ip link set sw1p0.1 master sw1.1
> >>>ip link set sw1p1.1 master sw1.1
> >>>
> >>>Does that fit the model correctly?

Why not make every switch a bridge (for the user POV) from the beginning
and send bridge netlink messages to switchdev then?

Greetings,

  Hannes
