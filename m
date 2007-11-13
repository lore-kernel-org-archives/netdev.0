From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: [PATCH][IPv6] Add ifindex field in ND user option messages
Date: Tue, 13 Nov 2007 01:54:13 +0100
Message-ID: <20071113005413.GA1767@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, rdenis@simphalempin.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:46630 "EHLO smtp4-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131AbXKMAyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 19:54:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userland neighbor discovery options are typically heavily involved with
the interface on which thay are received: add a missing ifindex field t=
o
the original struct. Thanks to R=E9mi Denis-Courmont.

Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5bf6182..4e81836 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -491,9 +491,11 @@ struct nduseroptmsg
 	unsigned char	nduseropt_family;
 	unsigned char	nduseropt_pad1;
 	unsigned short	nduseropt_opts_len;	/* Total length of options */
+	int		nduseropt_ifindex;
 	__u8		nduseropt_icmp_type;
 	__u8		nduseropt_icmp_code;
 	unsigned short	nduseropt_pad2;
+	unsigned int	nduseropt_pad3;
 	/* Followed by one or more ND options */
 };
=20
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 36f7dbf..67997a7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1037,6 +1037,7 @@ static void ndisc_ra_useropt(struct sk_buff *ra, =
struct nd_opt_hdr *opt)
=20
 	ndmsg =3D nlmsg_data(nlh);
 	ndmsg->nduseropt_family =3D AF_INET6;
+	ndmsg->nduseropt_ifindex =3D ra->dev->ifindex;
 	ndmsg->nduseropt_icmp_type =3D icmp6h->icmp6_type;
 	ndmsg->nduseropt_icmp_code =3D icmp6h->icmp6_code;
 	ndmsg->nduseropt_opts_len =3D opt->nd_opt_len << 3;

--=20
Pierre Ynard
=46or hire in Quebec City, Canada, during Fall 2007
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
