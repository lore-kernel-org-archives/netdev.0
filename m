From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Wed, 3 Sep 2003 09:10:34 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309030900530.14208-100000@netcore.fi>
References: <Pine.LNX.4.44.0309021854500.1730-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <yoshfuji@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309021854500.1730-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2003, Ville Nuorvala wrote:
> On Tue, 2 Sep 2003, Pekka Savola wrote:
> 
> > Two comments:
> >
> > +       /* try to inherit EUI64 from another device */
> > +       for (dev = dev_base; dev; dev = dev->next) {
> > +               if (!ipv6_generate_eui64(addr.s6_addr + 8, dev)) {
> > +                       addrconf_add_linklocal(idev, &addr);
> > +                       return;
> > +
> >
> > ==> does this really inherit _EUI64_, *or* MAC address (or something like
> > it) to derive an EUI64?  Note that there is a significant difference when
> > you've configured manually e.g. 3ffe:ffff:f00:ba::1 on a device, and the
> > case when you've auto-configured the interface identifier from the MAC
> > address of the device.
> 
> ipv6_generate_eui64() derives the interface identifier from the MAC
> address on ARPHRD_{ETHER,FDDI,IEEE802_TR,ARCNET} interfaces, but doesn't
> do anything for other types of devices

Ok, but then the command should be:

/* try to inherit MAC address from another device, to build an EUI64 */

> > ==> my question is: as the former method to steal an EUI64 should succeed
> > pretty much always, is it useful to add basically dead code which never
> > gets executed here?  I certainly can't think of any scenario where you'd
> > have no interface to steal the MAC address/EUI64 from and you'd have to
> > fall back to random identifiers?
> 
> If the node doesn't have an Ethernet (etc.) NIC it won't get a valid
> identifier from ipv6_generate_eui64() and has to resort to something
> else, for example generating a random address.

And exactly how often does this happen? Eth (all variants), FDDI, TR, 
ARCnet.. what's missing?  Does IPv6 even work with any other physical 
interfaces? :-)
 
> An alternative would be to use ipv6_inherit_eui64(), which just copies the
> 64-bit suffix from the first link-local address it can find. This includes
> both manually and auto-configured addresses, which means the risk of
> duplicate addresses might be (I assume) greater than in the random address
> case.

A possible twist here could be to copy only those whose universal/local 
bits indicate that that address was NOT manually configured, i.e..:

2001:708:10:40:207:e9ff:fe7b:259
               ^
            this one

.. but as stated, I'm not sure this is really necessary anyway either.

Note: it is desirable to have link-local addresses reasonably stable.  
Randomizing them may not be the right choice.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
