From: jamal <hadi@cyberus.ca>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 16:04:50 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204141553060.10326-100000@shell.cyberus.ca>
References: <D4CA6B275AA33241AC771F0C0B43A921010CE7E0@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921010CE7E0@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org



On Sun, 14 Apr 2002, Milam, Chad wrote:

> I lowered the timeout to make gc more agressive.  Though, it can still
> be adjusted via a /proc entry.  Default was 300. Increasing the other
> parameters that you specified (which I have done) only delays the
> inevitable "dst cache overflow".  The problem is that gc (rather
> rt_free) is not decrementing .entries.  So it _thinks_ the table
> has overflown.
>

Overflow will only happen if /proc/sys/net/ipv4/route/gc_thresh
is exceeded. A default of 512 aint that big. What is the average number
of entries you are seeing?
What kind of data do you get from running rtstat?
Increment the size of /proc/sys/net/ipv4/route/gc_thresh to a higher
number matching your avg entries;

Garbage collection aint that cheap: so safer to just make the size
larger instead of invoking it more frequently -- RAM is cheap. Note also
that garbage collection will run every
/proc/sys/net/ipv4/route/gc_min_interval time expiry regardless of how
you big your max threshold is.

cheers,
jamal
