From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: primary and secondary ip addresses
Date: Thu, 16 Dec 2004 11:53:51 +0200
Message-ID: <200412161153.51251.hasso@estpak.ee>
References: <41912F7A.6000408@redhat.com> <Pine.LNX.4.61.0411100034320.10593@filer.marasystems.com> <20041216092831.GO2862@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Henrik Nordstrom <hno@marasystems.com>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041216092831.GO2862@sunbeam.de.gnumonks.org>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> [Cc'ing netdev, since nobody replied since november]
> On Wed, Nov 10, 2004 at 12:38:19AM +0100, Henrik Nordstrom wrote:
> > A more valid question is why one can not add more than one primary in
> > the same subnet.
> >
> > ip addr add x.x.x.x/y dev eth0 primary
> >
> > would make sense to me, clearly indicating that these addresses are
> > maintained separately.
>
> agreed.

And why I can't even choose which address is primary?

> > or put in another way why the addresses automatically become secondary
> > addresses to the first added address.
>
> ... and why does removing the primary address remove all secondary
> addresses.  This makes it complicated if you have one interface with
> multiple ip addresse, that change over time (failover, let's say.)  You
> don't know yet, which address you need to remove, because you don't know
> which of your peers fails.
>
> So you have all this complicated userspace magic that checks whether the
> address that is about to be deleted is the primary, and if yes, re-add
> all the other addresses.  If if is a secondary, you're happy and only
> need to delete that one.
>
> Can anyone comment what the idea of all this was?

This reminds me related issue ... Actually there is concept in Junos 
software I'd love to see in Linux as well. There is "preferred address" and 
"primary address" in Junos. Quoting Junos documentation:

**************************************************************************

Primary
=======

Configure this address to be the primary address of the protocol on 
the interface. If the logical unit has more than one address, the 
primary address is used by default as the source address when packets 
originate from the interface and the destination does not indicate 
the subnet (ie. multicast destination for example). 

Default

For unicast traffic, the primary address is the lowest non-127
preferred address on the unit.

Preferred
=========

Configure this address to be the preferred address on the interface. 
If you configure more than one address on the same subnet, the 
preferred source address is chosen by default as the source address 
when you originate packets to destinations on the subnet. 

Default

The lowest numbered address on the subnet is the preferred address.
**************************************************************************

Would it be overkill for Linux? From the routers point of view it does make 
perfect sense. And of course you can manually override defaults in Junos.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
