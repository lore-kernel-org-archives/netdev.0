From: josef Jeff Sipek <jeffpc@optonline.net>
Subject: [PATCH/RFC 2.6] NET: 64-bit network statistics
Date: Fri, 03 Sep 2004 13:06:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409031307.01240.jeffpc@optonline.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I've created a patch that monitors changes to the network statistics variables 
and keeps internal 64-bit counter. I decided to split it into two parts 
(patches are to follow in next emails):
 1) generic variable monitoring system (watch64)

The watch64 system allows the programmer to specify the approximate interval 
at which he wants his variables checked. If he tries to specify shorter 
interval than the minimum a default value of HZ/10 is used. To minimize 
locking, RCU and seqlock are used. On 64-bit systems, all is optimized away. 

 2) network statistics specific patch (64network)

Upon registration of a network device, all the statistics variables are 
registered with watch64. Additionally, a new proc file is 
created /proc/net/dev64 displays the 64-bit values as supposed 
to /proc/net/dev which is left to display the original 32-bit variables for 
backward compatibility. The sysfs interface 
(/sys/class/net/<interface>/statistics/*) displays the 64-bit values only. On 
64-bit systems, all is optimized away through watch64.

Josef "Jeff" Sipek.

- -- 
*NOTE: This message is ROT-13 encrypted twice for extra protection*
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBOKSzwFP0+seVj/4RAkz7AJ0Ut21nPMkHGKv1dXK17yoA5hQ1+ACglpMq
IHh+tYW3innmwjlA7EU2x78=
=LnHg
-----END PGP SIGNATURE-----
