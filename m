From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Mon, 8 Apr 2002 07:59:29 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204072343250.12041-100000@shell.cyberus.ca>
References: <200204072211.g37MB3v06124@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <200204072211.g37MB3v06124@marajade.sandelman.ottawa.on.ca>
List-Id: netdev.vger.kernel.org



On Sun, 7 Apr 2002, Michael Richardson wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
>
>
> >>>>> "jamal" == jamal  <hadi@cyberus.ca> writes:
>     >> -IFOP_DOWN_LOWERLAYER
>     >> Lower layer is down, f.e. ethernet interfaces below a VLAN
>     >> -IFOP_DOWN_NOCARRIER
>     >> Interface link beat/framing is missing (current netif_carrier_o* maps
>     >> here)
>
>   Are there docs on these interfaces somewhere?
>

I guess this discussion will result in some documentation...

>     jamal> Good naming convention for the above two.
>
>     >> -IFOP_DOWN_KEEPALIVE
>     >> Another form of keepalive is missing
>
>     jamal> Not clear on this one.
>
>   PPP, for instance, does keepalives.
>   An IPsec tunnel might also use such a mechanism (we have plans).
>

Well, in that case the device is actually IFOP_UP. And the keepalives
could be looked at as "carrier/link level diagnostics". Should the
heartbeats disappear, it would be fair to transition the device to
IFOP_DOWN_NOCARRIER. Should the device underneath have its carrier
dissapear (eg a cable removed on an ethernet which ipsec0 uses), then
the transition is very quickly to IFOP_DOWN_LOWERLAYER.... I guess the
device(ipsec0) may also transition to IFOP_DOWN_NOCARRIER since its
carrier path is doewn etc.

>     jamal> Also the only time IFOP_DOWN_LOWERLAYER makes sense is when the top
>     jamal> stacked device is actually admin up (but none of the lower devices are
>     jamal> operationally UP)
>
>   There are very good operational reasons why this is often done...
>   It would be nice to see this kind of stuff in diagnostics.

I think they should be accessible; whether you send netlink
advertisements everytime there is some state transition is the question.
In my opinion the only interesting things are the a transition from a case
where a carrier (ethernet cable) is connected to where it is disconnected.
The other direction is also important. For example, i think these are the
only two route daemons need to know about.

cheers,
jamal
