From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
 reports
Date: Wed, 22 Sep 2010 16:33:14 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009221631520.32661@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home>
 <4C9A6D87.2000103@rincon.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C9A6D87.2000103-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2010, Bob Arendt wrote:

> multicast traffic is received. While IGMPv2 defines an "Unsolicited Report
> Interval" default of 10 seconds, it appears that this is a significant enough
> issue that the later IGMPv3 document calls out a default of 1 second, and
> goes on to define a "Robustness Variable" and talks about the same case that
> Christoph is trying to mitigate.

Actually that suggests a different way to reach the same goal:


Subject: igmp: Make unsolicited report interval conform to RFC3376

RFC3376 specifies a shorter time interval for sending igmp joins.
This can address issues where joins are slow because the initial join is
frequently lost.

Also increment the frequency so that we get a 10 reports send over a
few seconds.

Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>


---
 net/ipv4/igmp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/net/ipv4/igmp.c
===================================================================
--- linux-2.6.orig/net/ipv4/igmp.c	2010-09-22 16:28:17.000000000 -0500
+++ linux-2.6/net/ipv4/igmp.c	2010-09-22 16:28:54.000000000 -0500
@@ -114,9 +114,9 @@

 #define IGMP_V1_Router_Present_Timeout		(400*HZ)
 #define IGMP_V2_Router_Present_Timeout		(400*HZ)
-#define IGMP_Unsolicited_Report_Interval	(10*HZ)
+#define IGMP_Unsolicited_Report_Interval	(HZ)
 #define IGMP_Query_Response_Interval		(10*HZ)
-#define IGMP_Unsolicited_Report_Count		2
+#define IGMP_Unsolicited_Report_Count		10


 #define IGMP_Initial_Report_Delay		(1)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
