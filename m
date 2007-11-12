From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [Resend][PATCH 01/05] ipv6: RFC4214 Support (4)
Date: Mon, 12 Nov 2007 13:01:13 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:37162 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759752AbXKLVBf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 16:01:35 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

-----Original Message-----
From: osprey67 [mailto:osprey67@yahoo.com] 
Sent: Monday, November 12, 2007 7:54 AM
To: netdev@vger.kernel.org
Subject: [PATCH 01/05] ipv6: RFC4214 Support (4)

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.24-rc2/include/linux/if.h.orig    2007-11-08
12:05:47.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/if.h 2007-11-08 08:26:44.000000000
-0800
@@ -61,6 +61,7 @@
  #define IFF_MASTER_ALB 0x10            /* bonding master, balance-alb.
*/
  #define IFF_BONDING    0x20            /* bonding master or slave
*/
  #define IFF_SLAVE_NEEDARP 0x40         /* need ARPs for validation
*/
+#define IFF_ISATAP     0x80            /* ISATAP interface (RFC4214)
*/

  #define IF_GET_IFACE   0x0001          /* for querying only */
  #define IF_GET_PROTO   0x0002
--- linux-2.6.24-rc2/include/linux/in.h.orig    2007-11-09
08:00:32.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/in.h 2007-11-12 07:37:05.000000000
-0800
@@ -253,6 +253,14 @@ struct sockaddr_in {
  #define ZERONET(x)     (((x) & htonl(0xff000000)) ==
htonl(0x00000000))
  #define LOCAL_MCAST(x) (((x) & htonl(0xFFFFFF00)) ==
htonl(0xE0000000))

+/* Special-Use IPv4 Addresses (RFC3330) */
+#define PRIVATE_10(x)  (((x) & htonl(0xff000000)) == htonl(0x0A000000))
+#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) ==
htonl(0xA9FE0000))
+#define PRIVATE_172(x) (((x) & htonl(0xfff00000)) == htonl(0xAC100000))
+#define TEST_192(x)    (((x) & htonl(0xffffff00)) == htonl(0xC0000200))
+#define ANYCAST_6TO4(x)        (((x) & htonl(0xffffff00)) ==
htonl(0xC0586300))
+#define PRIVATE_192(x) (((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
+#define TEST_198(x)    (((x) & htonl(0xfffe0000)) == htonl(0xC6120000))
  #endif

  #endif /* _LINUX_IN_H */
--- linux-2.6.24-rc2/include/net/addrconf.h.orig        2007-11-08
12:06:17.000000000 -0800
+++ linux-2.6.24-rc2/include/net/addrconf.h     2007-11-09
08:12:29.000000000 -0800
@@ -241,6 +241,14 @@ static inline int ipv6_addr_is_ll_all_ro
                 addr->s6_addr32[3] == htonl(0x00000002));
  }

+#if defined(CONFIG_IPV6_ISATAP)
+/* only for IFF_ISATAP interfaces */
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+       return ((addr->s6_addr32[2] | htonl(0x02000000)) ==
htonl(0x02005EFE));
+}
+#endif
+
  #ifdef CONFIG_PROC_FS
  extern int if6_proc_init(void);
  extern void if6_proc_exit(void);




-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
