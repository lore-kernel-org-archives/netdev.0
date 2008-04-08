From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL net-2.6.26] [IPV6] MROUTE: Support multicast routing.
Date: Tue, 08 Apr 2008 02:14:07 -0700 (PDT)
Message-ID: <20080408.021407.103894702.davem@davemloft.net>
References: <147a89290804070613o5274432frb50995433a9a95f3@mail.gmail.com>
	<20080407.233709.01728201.yoshfuji@linux-ipv6.org>
	<147a89290804072357i3bccbe81tfa6bb4b3d0331592@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: johnsonzjo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751681AbYDHJOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 05:14:07 -0400
In-Reply-To: <147a89290804072357i3bccbe81tfa6bb4b3d0331592@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Andy Johnson" <johnsonzjo@gmail.com>
Date: Tue, 8 Apr 2008 09:57:39 +0300

> mld6.c: In function 'init_mld6':
> mld6.c:210: error: 'ICMP6_MEMBERSHIP_QUERY' undeclared (first use in
> this function)
> mld6.c:210: error: (Each undeclared identifier is reported only once
> mld6.c:210: error: for each function it appears in.)
> mld6.c:211: error: 'ICMP6_MEMBERSHIP_REPORT' undeclared (first use in
> this function)
> mld6.c:212: error: 'ICMP6_MEMBERSHIP_REDUCTION' undeclared (first use
> in this function)
> mld6.c: In function 'accept_mld6':
> mld6.c:451: error: 'MLD_LISTENER_DONE' undeclared (first use in this function)

Somewhere along the line ICMP6_MEMBERSHIP_* got changed
into MLD_LISTENER_* in the glibc headers.

Similarly MLD_LISTENER_DONE should be MLD_LISTENER_REDUCTION.

In glibc-2.3.x both defines were provided, but after that the old
ICMP6_* defines were completely removed.

Probably Yoshifuji-san tests the user tool builds on a glibc-2.3.x or
earlier system, which has the old deprecated defines.

So if you simply change:

	ICMP6_MEMBERSHIP_* --> MLD_LISTENER_*

and also:

	MLD_LISTENER_DONE --> MLD_LISTENER_REDUCTION

the build will complete successfully.
