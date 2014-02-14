From: Dave Jones <davej@redhat.com>
Subject: suspicious code in net/rxrpc/ar-error.c
Date: Thu, 13 Feb 2014 21:28:15 -0500
Message-ID: <20140214022815.GA19030@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbaBNC2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 21:28:23 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1E2SMap023687
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 21:28:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking through old coverity reports, I came across this..

 84                 if (mtu == 0) {
 85                         /* they didn't give us a size, estimate one */
 86                         if (mtu > 1500) {
 87                                 mtu >>= 1;
 88                                 if (mtu < 1500)
 89                                         mtu = 1500;
 90                         } else {
 91                                 mtu -= 100;
 92                                 if (mtu < peer->hdrsize)
 93                                         mtu = peer->hdrsize + 4;
 94                         }
 95                 }

What was intended here ? Perhaps one of those mtu comparisons should be
comparing peer->mtu ?

	Dave
