From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IFA_MAX sets wrong in rtnetlink.h
Date: Fri, 28 May 2004 18:27:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040528.182703.93063703.yoshfuji@linux-ipv6.org>
References: <20040528.134802.953480362.yoshfuji@linux-ipv6.org>
	<20040527220756.7c41a55b.davem@redhat.com>
	<20040528.141200.564308976.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040528.141200.564308976.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040528.141200.564308976.yoshfuji@linux-ipv6.org> (at Fri, 28 May 2004 14:12:00 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20040527220756.7c41a55b.davem@redhat.com> (at Thu, 27 May 2004 22:07:56 -0700), "David S. Miller" <davem@redhat.com> says:
> 
> > On Fri, 28 May 2004 13:48:02 +0900 (JST)
> > YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> > 
> > > enum {
> > >      :
> > >      IFA_CACHEINFO,
> > >      IFA_MULTICAST,   /* added */
> > >      __IFA_MAX
> > > };
> > > 
> > > #define IFA_MAX (__IFA_MAX - 1)
> > 
> > I like this last technique the best, one-line diffs :-)
> 
> Ok, I'll do this.

Here's the patch for 2.4.

===== include/linux/pkt_cls.h 1.1 vs edited =====
--- 1.1/include/linux/pkt_cls.h	2002-02-06 02:39:42 +09:00
+++ edited/include/linux/pkt_cls.h	2004-05-28 17:25:08 +09:00
@@ -24,11 +24,12 @@
 	TCA_POLICE_RATE,
 	TCA_POLICE_PEAKRATE,
 	TCA_POLICE_AVRATE,
-	TCA_POLICE_RESULT
+	TCA_POLICE_RESULT,
 #define TCA_POLICE_RESULT TCA_POLICE_RESULT
+	__TCA_POLICE_MAX
 };
 
-#define TCA_POLICE_MAX TCA_POLICE_RESULT
+#define TCA_POLICE_MAX (__TCA_POLICE_MAX - 1)
 
 /* U32 filters */
 
@@ -49,9 +50,10 @@
 	TCA_U32_DIVISOR,
 	TCA_U32_SEL,
 	TCA_U32_POLICE,
+	__TCA_U32_MAX
 };
 
-#define TCA_U32_MAX TCA_U32_POLICE
+#define TCA_U32_MAX (__TCA_U32_MAX - 1)
 
 struct tc_u32_key
 {
@@ -97,9 +99,10 @@
 	TCA_RSVP_SRC,
 	TCA_RSVP_PINFO,
 	TCA_RSVP_POLICE,
+	__TCA_RSVP_MAX
 };
 
-#define TCA_RSVP_MAX TCA_RSVP_POLICE
+#define TCA_RSVP_MAX (__TCA_RSVP_MAX - 1)
 
 struct tc_rsvp_gpi
 {
@@ -127,9 +130,10 @@
 	TCA_ROUTE4_FROM,
 	TCA_ROUTE4_IIF,
 	TCA_ROUTE4_POLICE,
+	__TCA_ROUTE4_MAX
 };
 
-#define TCA_ROUTE4_MAX TCA_ROUTE4_POLICE
+#define TCA_ROUTE4_MAX (__TCA_ROUTE4_MAX - 1)
 
 
 /* FW filter */
@@ -139,9 +143,10 @@
 	TCA_FW_UNSPEC,
 	TCA_FW_CLASSID,
 	TCA_FW_POLICE,
+	__TCA_FW_MAX
 };
 
-#define TCA_FW_MAX TCA_FW_POLICE
+#define TCA_FW_MAX (__TCA_FW_MAX - 1)
 
 /* TC index filter */
 
@@ -154,8 +159,9 @@
 	TCA_TCINDEX_FALL_THROUGH,
 	TCA_TCINDEX_CLASSID,
 	TCA_TCINDEX_POLICE,
+	__TCA_TCINDEX_MAX
 };
 
-#define TCA_TCINDEX_MAX        TCA_TCINDEX_POLICE
+#define TCA_TCINDEX_MAX        (__TCA_TCINDEX_MAX - 1)
 
 #endif
===== include/linux/rtnetlink.h 1.11 vs edited =====
--- 1.11/include/linux/rtnetlink.h	2003-12-03 09:28:24 +09:00
+++ edited/include/linux/rtnetlink.h	2004-05-28 18:03:19 +09:00
@@ -113,9 +113,10 @@
 	RTN_THROW,		/* Not in this table		*/
 	RTN_NAT,		/* Translate this address	*/
 	RTN_XRESOLVE,		/* Use external resolver	*/
+	__RTN_MAX
 };
 
-#define RTN_MAX RTN_XRESOLVE
+#define RTN_MAX (__RTN_MAX - 1)
 
 
 /* rtm_protocol */
@@ -178,9 +179,10 @@
 /* User defined values */
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
-	RT_TABLE_LOCAL=255
+	RT_TABLE_LOCAL=255,
+	__RT_TABLE_MAX
 };
-#define RT_TABLE_MAX RT_TABLE_LOCAL
+#define RT_TABLE_MAX (__RT_TABLE_MAX - 1)
 
 
 
@@ -200,10 +202,11 @@
 	RTA_MULTIPATH,
 	RTA_PROTOINFO,
 	RTA_FLOW,
-	RTA_CACHEINFO
+	RTA_CACHEINFO,
+	__RTA_MAX
 };
 
-#define RTA_MAX RTA_CACHEINFO
+#define RTA_MAX (__RTA_MAX - 1)
 
 #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct rtmsg))))
 #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
@@ -282,9 +285,10 @@
 #define RTAX_ADVMSS RTAX_ADVMSS
 	RTAX_REORDERING,
 #define RTAX_REORDERING RTAX_REORDERING
+	__RTAX_MAX
 };
 
-#define RTAX_MAX RTAX_REORDERING
+#define RTAX_MAX (__RTAX_MAX - 1)
 
 
 
@@ -309,10 +313,11 @@
 	IFA_LABEL,
 	IFA_BROADCAST,
 	IFA_ANYCAST,
-	IFA_CACHEINFO
+	IFA_CACHEINFO,
+	__IFA_MAX
 };
 
-#define IFA_MAX IFA_CACHEINFO
+#define IFA_MAX (__IFA_MAX - 1)
 
 /* ifa_flags */
 
@@ -360,10 +365,11 @@
 	NDA_UNSPEC,
 	NDA_DST,
 	NDA_LLADDR,
-	NDA_CACHEINFO
+	NDA_CACHEINFO,
+	__NDA_MAX
 };
 
-#define NDA_MAX NDA_CACHEINFO
+#define NDA_MAX (__NDA_MAX - 1)
 
 #define NDA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndmsg))))
 #define NDA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
@@ -448,10 +454,11 @@
 #define IFLA_WIRELESS IFLA_WIRELESS
 	IFLA_PROTINFO,		/* Protocol specific information for a link */
 #define IFLA_PROTINFO IFLA_PROTINFO
+	__IFLA_MAX
 };
 
 
-#define IFLA_MAX IFLA_PROTINFO
+#define IFLA_MAX (__IFLA_MAX - 1)
 
 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
@@ -493,9 +500,10 @@
 	IFLA_INET6_CONF,	/* sysctl parameters		*/
 	IFLA_INET6_STATS,	/* statistics			*/
 	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
+	__IFLA_INET6_MAX
 };
 
-#define IFLA_INET6_MAX	IFLA_INET6_MCAST
+#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
 /*****************************************************************
  *		Traffic control messages.
@@ -520,9 +528,10 @@
 	TCA_STATS,
 	TCA_XSTATS,
 	TCA_RATE,
+	__TCA_MAX
 };
 
-#define TCA_MAX TCA_RATE
+#define TCA_MAX (__TCA_MAX - 1)
 
 #define TCA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcmsg))))
 #define TCA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcmsg))

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
