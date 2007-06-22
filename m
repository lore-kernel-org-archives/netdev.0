From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 01:42:41 +0200
Message-ID: <200706230142.41188.mb@bu3sch.de>
References: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54428
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbXFVXnH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 19:43:07 -0400
In-Reply-To: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 23 June 2007 01:26:19 C. Scott Ananian wrote:
> +struct rdns6_info {
> +=A0=A0=A0=A0=A0=A0=A0rwlock_t=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0lock;
> +=A0=A0=A0=A0=A0=A0=A0struct timer_list=A0=A0=A0=A0=A0=A0=A0expiry_ti=
mer;
> +=A0=A0=A0=A0=A0=A0=A0struct rdns6_entry *=A0=A0=A0=A0rdnss_list;
> +=A0=A0=A0=A0=A0=A0=A0struct inet6_dev *=A0=A0=A0=A0=A0=A0in6_dev; /*=
 back pointer for netlink notify */
> +=A0=A0=A0=A0=A0=A0=A0int=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0expire_all : 1, /* remove entries on ifdown */
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0free_me : 1; /* safely free this struct */
> +};

Sparse will complain about that.
I suggest you do:

+struct rdns6_info {
+       rwlock_t                lock;
+       struct timer_list       expiry_timer;
+       struct rdns6_entry *    rdnss_list;
+       struct inet6_dev *      in6_dev; /* back pointer for netlink no=
tify */
+       u8                     expire_all; /* remove entries on ifdown =
*/
+       u8                     free_me; /* safely free this struct */
+};

Will generate better code and
struct size shouldn't increase. So it's a net win.

--=20
Greetings Michael.
