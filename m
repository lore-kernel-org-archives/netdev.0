From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 16:44:06 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921011BE867@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

> On Sun, 14 Apr 2002, Milam, Chad wrote:
> 
> > /proc/sys/net/ipv4/route/max_size=16384 (default 4096)
> 
> Ok, i meant:
> /proc/sys/net/ipv4/route/gc_thresh

it also looks like gc_thresh defaults to RT_HASH_DIVISOR (256).

however I have....
/proc/sys/net/ipv4/route/gc_thresh=2048

> > Also, based on the code from route.c:
> > --
> > if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
> >         return 0;
> > if (net_ratelimit())
> > 	printk("dst cache overflow\n");
> > return 1;
> > --
> >
> 
> 0 typically means the gc was succesful

true enough.  but the way I read that is that if entries>max_size,
you are going to get "dst cache overflow" which returns a 1. there
is no test here for entries>gc_thresh.

> I just remembered an old problem that used to cause this; do you
> have lo configured?
> make sure it is IP address 127.0.0.1 and it is up.

sure do. read about that issue quite sometime ago.

thanks again,
chad
