From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 15:58:11 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921011BE86B@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>,
   "Julian Anastasov <ja@ssi.bg>" <IMCEANOTES-+22Julian+20Anastasov+20+3Cja+40ssi+2Ebg+3E+22@avee-health.com>
List-Id: netdev.vger.kernel.org


Julian wrote:
> On Mon, 15 Apr 2002, Milam, Chad wrote:
> 
> > > can only give you some CPU cycles. Touching max_size should be
> > > enough.
> >
> > no. Increasing max_size only delays its death. That is my point. The problem
> > existed on an out of the box RH7, RH6.2, RH6.1 install. The whole point of the
> > patch was to fix a problem that existed _prior_ to me patching it.
> 
> 	I assume you mean a plain kernel (without Check Point?).

indeed.. out of the box, nothing installed additional, ip params tuned.

> 
> > > 	Are you sure you have stalled entries? What shows /proc/slabinfo
> > > after 22 hours (skbuff_head_cache, etc)?
> >
> > well, what I can tell you is this. If I run a loop like the following, counter
> > will only show say, 50 routes in the cache.
> 
> 	It means there are 50 linked cache entries but the
> ipv4_dst_ops.entries reaches the limit, very strange.

this is what I am keep trying to say :)

 
> > > for i in down up ; do ip link set ethXXX $i ; done
> >
> > downing all interfaces and reupping them does not seem to solve the problem either :S
> 
> 	I mean when you see the dst cache overflow message can the
> command help? But ... may be are running a kernel patched with your
> changes. I'm asking this because I know cases where wrong changes
> can make problems with dst cache. But the plain kernel should be
> fine. One question more: can you say that this box is used only as
> router or what kind of TCP or UDP connections you have (to/from the
> box)? There can be some corner cases in the dst cache usage from
> connected sockets.

I originally setup a script to do basically this... grep "dst cache" 
/var/log/messages; if i get a hit, down and up all interfaces.  that didnt
work, so then I changed it to reboot the box :(.  This was done on a box
with _no_ funny stuff... again, bog standard.

The box is a router, no ip masq, no ip chains, no ip fw, just a router.

Thanks,
chad
