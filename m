From: Julian Anastasov <ja@ssi.bg>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 22:53:06 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204152232230.1201-100000@u.domain.uli>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE86A@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com,
   "Julian Anastasov <ja@ssi.bg>" <IMCEANOTES-Julian+20Anastasov+20+3Cja+40ssi+2Ebg+3E@avee-health.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE86A@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 15 Apr 2002, Milam, Chad wrote:

> > can only give you some CPU cycles. Touching max_size should be
> > enough.
>
> no. Increasing max_size only delays its death. That is my point. The problem
> existed on an out of the box RH7, RH6.2, RH6.1 install. The whole point of the
> patch was to fix a problem that existed _prior_ to me patching it.

	I assume you mean a plain kernel (without Check Point?).

> > 	Are you sure you have stalled entries? What shows /proc/slabinfo
> > after 22 hours (skbuff_head_cache, etc)?
>
> well, what I can tell you is this. If I run a loop like the following, counter
> will only show say, 50 routes in the cache.

	It means there are 50 linked cache entries but the
ipv4_dst_ops.entries reaches the limit, very strange.

> > for i in down up ; do ip link set ethXXX $i ; done
>
> downing all interfaces and reupping them does not seem to solve the problem either :S

	I mean when you see the dst cache overflow message can the
command help? But ... may be are running a kernel patched with your
changes. I'm asking this because I know cases where wrong changes
can make problems with dst cache. But the plain kernel should be
fine. One question more: can you say that this box is used only as
router or what kind of TCP or UDP connections you have (to/from the
box)? There can be some corner cases in the dst cache usage from
connected sockets.

> thanks,
> chad

Regards

--
Julian Anastasov <ja@ssi.bg>
