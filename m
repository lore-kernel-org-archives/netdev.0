From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 16:25:52 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921011BE866@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

> On Sun, 14 Apr 2002, Milam, Chad wrote:
> 
> > I lowered the timeout to make gc more agressive.  Though, it can still
> > be adjusted via a /proc entry.  Default was 300. Increasing the other
> > parameters that you specified (which I have done) only delays the
> > inevitable "dst cache overflow".  The problem is that gc (rather
> > rt_free) is not decrementing .entries.  So it _thinks_ the table
> > has overflown.
> >
> 
> Overflow will only happen if /proc/sys/net/ipv4/route/gc_thresh
> is exceeded. A default of 512 aint that big. What is the average number
> of entries you are seeing?
> What kind of data do you get from running rtstat?
> Increment the size of /proc/sys/net/ipv4/route/gc_thresh to a higher
> number matching your avg entries;
> 
> Garbage collection aint that cheap: so safer to just make the size
> larger instead of invoking it more frequently -- RAM is cheap. Note also
> that garbage collection will run every
> /proc/sys/net/ipv4/route/gc_min_interval time expiry regardless of how
> you big your max threshold is.
> 
> cheers,
> jamal

Actually changing the timer to 120*HZ was not supposed to end up in the patch, 
I pulled it out of there, but managed to leave it in the diff for the email.

/proc/sys/net/ipv4/route/gc_min_interval = 1
/proc/sys/net/ipv4/route/max_size=16384 (default 4096)

Also, based on the code from route.c:
--
if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
        return 0;
if (net_ratelimit())
	printk("dst cache overflow\n");
return 1;
--

Looks to me like gc_thresh has nothing to do with it. Did I read that wrong?

chad

 
