From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: ipv6: Do not depend on rt->n in rt6_probe().
Date: Mon, 21 Jan 2013 21:28:58 +0300
Message-ID: <20130121182858.GA8808@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kbuild@01.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39731 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3AUS3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:29:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E,

This is a semi-automatic email about new static checker warnings.

The patch 2152caea7196: "ipv6: Do not depend on rt->n in=20
rt6_probe()." from Jan 17, 2013, leads to the following Smatch=20
complaint:

net/ipv6/route.c:495 rt6_probe()
	 error: we previously assumed 'neigh' could be null (see line 490)

net/ipv6/route.c
   489=09
   490		if (!neigh ||
                     ^^^^^
New test.

   491		    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr=
_probe_interval)) {
   492			struct in6_addr mcaddr;
   493			struct in6_addr *target;
   494=09
   495			neigh->updated =3D jiffies;
                        ^^^^^^^^^^^^^^
Old dereference.

   496=09
   497			if (neigh)
                            ^^^^^
Another new test.

regards,
dan carpenter
