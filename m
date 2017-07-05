From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Unable to add v6 multipath route with same nexthops but different
 MPLS labels
Date: Wed, 5 Jul 2017 18:39:58 +0300
Message-ID: <20170705153958.GL22185@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:40578 "EHLO
        mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdGEPrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:47:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

FWIW, this doesn't work:

	# ip -6 route add 1234::/16 \
		nexthop encap mpls 10 via fe80::1 dev ens3 \
		nexthop encap mpls 20 via fe80::1 dev ens3
	RTNETLINK answers: File exists

While this does:

	# ip -6 route chg 1234::/16
		nexthop encap mpls 10 via fe80::1 dev ens3
		nexthop encap mpls 20 via fe80::2 dev ens3
	# ip -6 route
	1234::/16  encap mpls  10 via fe80::1 dev ens3 metric 1024 pref medium
	1234::/16  encap mpls  20 via fe80::2 dev ens3 metric 1024 pref medium
	[...]

ECMPing over different LSPs that share a nexthop router seems like a
legitimate use case to me.  Is this restriction intentional or just an
accident?  (The same thing works fine in v4 land, where multipath
routes are handled differently.)

Thanks in advance!


Cheers,
Lennert
