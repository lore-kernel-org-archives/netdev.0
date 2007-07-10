From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#199054: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Tue, 10 Jul 2007 13:58:51 +0200
Message-ID: <20070710115851.GA21929@scream.fatal.se>
Reply-To: Andreas Henriksson <andreas@fatal.se>,
	199054@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 199054@bugs.debian.org
To: netdev@vger.kernel.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.199054.B199054.118406947522827@bugs.debian.org>
Content-Disposition: inline
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Hello!

While investigating the problems reported in Debian bug #199054
(http://bugs.debian.org/199054), stating that the RX/TX bytes differ between
ifconfig and ip(route2) I came across this:

include/linux/if_link.h (used in kernel and iproute2 source):
/* The struct should be in sync with struct net_device_stats */
struct rtnl_link_stats
{
	__u32 ...;
	__u32 ...;
	__u32 ...;
	__u32 ...;
...


include/linux/netdevice.h:
struct net_device_stats
{
	unsigned long   ...;
	unsigned long   ...;
	unsigned long   ...;
	unsigned long   ...;
	unsigned long   ...;
....


This will be a problem when unsigned long isn't 32bits, but I guess the
rtnetlink message size is static for good reason. 
Can someone please advise on how to fix this?

-- 
Regards,
Andreas Henriksson
