From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: RFC: ethtool support for n-tuple filter programming
Date: Fri, 6 Nov 2009 11:12:45 -0800
Message-ID: <469958e00911061112y4d2d746cq93d90abfd6df7ec1@mail.gmail.com>
References: <1257533841.2610.12.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:43492 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759300AbZKFTMk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 14:12:40 -0500
Received: by pwj9 with SMTP id 9so806343pwj.21
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 11:12:45 -0800 (PST)
In-Reply-To: <1257533841.2610.12.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The approach you are proposing assumes what type of packet filters
that L2 hardware could support.

Why not simply use existing filtering rules that overshoot the target,
such as netfilter, and ask the
device specific tool to indicate what set of these rules it can support=
?


On Fri, Nov 6, 2009 at 10:57 AM, Peter P Waskiewicz Jr
<peter.p.waskiewicz.jr@intel.com> wrote:
> All,
>
> I'm looking to add support to ethtool that would allow programming of
> full n-tuple filters into underlying devices. =C2=A0Currently, ixgbe =
has
> support for these types of perfect match or mostly match (masked)
> filters. =C2=A0I imagine other hardware exists that also has support =
for
> this, so I'd like to make this interface usable for everyone.
>
> Note that this is similar behavior in the iproute2 tools, but it's
> different enough, in my opinion, to warrant being in ethtool. =C2=A0T=
he
> iproute2 tools (specifically tc) manipulate the qdiscs to add filters=
 in
> the kernel packet schedulers. =C2=A0This proposed solution is managin=
g the
> hardware in the underlying device, which iproute2 tools currently don=
't
> touch. =C2=A0Hopefully this is obvious for those reviewing this propo=
sal.
>
> What I currently have as possible inputs to ethtool are:
>
> - src/dst IP address: 32-bits each, 128-bits each for IPv6
> - src/dst port: 16-bits each (TCP/UDP)
> - VLAN tag: 15-bits
> - L4 type: 8-bits (TCP/UDP/SCTP currently, can grow later)
> - User specified field: currently 32-bits, can be anything a driver
> wants to use
> - Action: signed 16-bits (-1 indicates drop, any other value is the R=
x
> queue to steer the flow to)
>
> Now all of these fields, except action, can also have a mask supplied=
 to
> them, but it's not mandatory.
>
> An example ethtool command with this support could be:
>
> # ethtool -F ethX dst-ip 0x0101a8c0 src-ip 0x0001a8c0 0x00ffffff
> dst-port 0x1600 src-port 0x0000 0x0000 usr 0x8906 act 5
>
> This will program a filter that will filter traffic coming from
> 192.168.1.0/24 to 192.168.1.1, port 22, from any source port, and wil=
l
> place all those matches packets into Rx queue 5. =C2=A0It also specif=
ied a
> user-defined field of 0x8906, which a driver can use at its own
> discretion (or omit completely).
>
> Then running the ethtool -f ethX command could dump all currently
> programmed filters.
>
> Any comments, thoughts, suggestions, or ideas are welcome.
>
> Cheers,
> -PJ Waskiewicz
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
