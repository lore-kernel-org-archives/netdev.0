From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Sun, 13 Oct 2002 17:34:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210131726010.26803-100000@shell.cyberus.ca>
References: <200210132100.BAA09316@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200210132100.BAA09316@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 14 Oct 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > status. At the moment the only status is IFF_RUNNING in the ifi_flags.
> > So the question was could we use ifi_change to send the other pieces of
> > info
>
> No, of course. The question is really strange. :-)
>
> > If not, could we take advantage of that pad in the ifinfomsg?
>
> ifi_flags has lots of spare space, 16 bits.
>

Actually the extra flags are only valid when IFF_RUNNING is not set.
Maybe Stefan was pushing it to also want to flag tx operational failure ..

In any case please review his patch.

> And the second: IFF_RUNNING seems to be enough. Their "dormant" and
> "lowerLayerDown" are logically undistinuishable.

Some of those states are useless.
dormant may refer tothings like  tunnel devices on top of physical
devices. Example that was given was a ipsec tunnel sending pings
periodically;
lowerLayerDown is when you have multiple phyical devices under a
aggregator like bonding or maybe even VLAN; in that case if one of the
physical devices underneath being down would imply "lowerLayerDown" flag
on the aggregagator device. A second query would reveal which of the
underneath devices is down.

cheers,
jamal
