From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Force IPv6 FIB gc on device shutdown
Date: Fri, 9 Apr 2004 15:31:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409153117.490c9ba3.davem@redhat.com>
References: <20040409173901.62ebf75b.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tspat@de.ibm.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040409173901.62ebf75b.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks Andi.

A week ago Thomas Spatzier posted a similar patch, and I had
asked Stephen Hemminger (in private email) for his take on
this.

So here is the final patch I applied, based upon your and
Thomas's patches, plus Stephen's commentary.  (hint: NETDEV_DOWN
is sufficient, because unregister causes a NETDEV_DOWN event
if necessary).

Thanks everyone.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/04/09 15:29:23-07:00 davem@nuts.davemloft.net 
#   [IPV6]: In ndisc_netdev_event, handle NETDEV_DOWN.
#   
#   Based upon patches and commentary from Thomas Spatzier,
#   Stephen Hemminger, and Andi Kleen.
# 
# net/ipv6/ndisc.c
#   2004/04/09 15:29:00-07:00 davem@nuts.davemloft.net +4 -0
#   [IPV6]: In ndisc_netdev_event, handle NETDEV_DOWN.
#   
#   Based upon patches and commentary from Thomas Spatzier,
#   Stephen Hemminger, and Andi Kleen.
# 
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	Fri Apr  9 15:30:59 2004
+++ b/net/ipv6/ndisc.c	Fri Apr  9 15:30:59 2004
@@ -1403,6 +1403,10 @@
 		neigh_changeaddr(&nd_tbl, dev);
 		fib6_run_gc(0);
 		break;
+	case NETDEV_DOWN:
+		neigh_ifdown(&nd_tbl, dev);
+		fib6_run_gc(0);
+		break;
 	default:
 		break;
 	}
