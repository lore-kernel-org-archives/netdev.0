From: Julian Anastasov <ja@ssi.bg>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 21:31:21 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204152118390.21763-100000@l>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE869@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE869@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 15 Apr 2002, Milam, Chad wrote:

> I also do not think that nuking valid routes in the cache will produce any
> major issues, other than slowing things down for a few seconds.  the cache
> is just the cache, not the real route table. and yes, it pretty much

	Of course. You can play only with max_size to achieve the same
result. max_size should be appropriate to the rate new hosts appear
in the cache. I'm wondering whether your patched kernel does not have
some bug, for example, unfreed skbs or struct rtable. Make sure that
the unpatched kernels have the same bug. If it appears after 22
hours (I assume the system load for all these 22 hours is same)
then this is a bug. Playing with the hash size is final step but it
can only give you some CPU cycles. Touching max_size should be
enough.

> guarantees the route cache will be purged, therefore avoiding a reboot and
> avoiding a quickly repeated overflow...

	Are you sure you have stalled entries? What shows /proc/slabinfo
after 22 hours (skbuff_head_cache, etc)?

	One hint: can this command solve the problem (to flush the
cache entries)?:

for i in down up ; do ip link set ethXXX $i ; done

> chad

Regards

--
Julian Anastasov <ja@ssi.bg>
