From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: IPv6 autoconf oddity...  (2.4.21/2.4.22 kernels)
Date: Sat, 15 Nov 2003 23:11:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031115211104.GB2864@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have two nearly identical machines at two locations.
Or maybe not quite identical..  very nearly anyway.

Machine running somewhat modified RedHat Rawhide
2.4.21-20.1.2024.2.1.nptlmea receives RAs from a cisco
router, and autoconfigures nicely.

Machine running  RedHat Rawhide Fedora  2.4.22-1.2115.nptlsmp
kernel fails to autoconf.   That machine is receives RAs from
a NetBSD router's rtadvd.

Both machines run without any specific things to particularly
enable IPv6 in their configurations.  Besides of auto-loading
the ipv6 module.

Oddly the functioning pair isn't configured with EUI64=y setting,
but the failing one is.  Yet the cisco is configured to send
EUI64 RAs...

Any ideas ?

/Matti Aarnio


Cisco router advertisement:

21:28:24.008112 fe80::2b0:c2ff:fe89:c352 > ff02::1: icmp6:
	router advertisement(chlim=64, pref=medium, router_ltime=1800,
	reachable_time=0, retrans_time=0)(src lladdr: 00:b0:c2:89:c3:52)
	(prefix info: LA valid_ltime=2592000,preferred_ltime=604800,
	 prefix=2001:14b8:0:3001::/64) [class 0x70] (len 56, hlim 255)
0x0000   6700 0000 0038 3aff fe80 0000 0000 0000        g....8:.........
0x0010   02b0 c2ff fe89 c352 ff02 0000 0000 0000        .......R........
0x0020   0000 0000 0000 0001 8600 b5b6 4000 0708        ............@...
0x0030   0000 0000 0000 0000 0101 00b0 c289 c352        ...............R
0x0040   0304 40c0 0027 8d00 0009 3a80 0000 0000        ..@..'....:.....
0x0050   2001 14b8 0000 3001 0000 0000 0000 0000        ......0.........


NetBSD rtadvd advertisemenent:

# 21:18:42.468714 fe80::200:e2ff:fe70:341f > all-nodes-mc: icmp6:
	router advertisement(chlim=64, pref=medium, router_ltime=90,
	reachable_time=0, retrans_time=0)(src lladdr: 00:00:e2:70:34:1f)
	(prefix info: LA valid_ltime=2592000,preferred_ltime=604800,
	 prefix=2001:14b8:0:3003::/64) (len 56, hlim 255)
0x0000   6000 0000 0038 3aff fe80 0000 0000 0000        `....8:.........
0x0010   0200 e2ff fe70 341f ff02 0000 0000 0000        .....p4.........
0x0020   0000 0000 0000 0001 8600 9c5b 4000 005a        ...........[@..Z
0x0030   0000 0000 0000 0000 0101 0000 e270 341f        .............p4.
0x0040   0304 40c0 0027 8d00 0009 3a80 0000 0000        ..@..'....:.....
0x0050   2001 14b8 0000 3003 0000 0000 0000 0000        ......0.........
