From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch added to 3.12-stable] net: sctp, forbid negative length
Date: Thu, 24 Nov 2016 12:51:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02275D7@AcuExch.aculab.com>
References: <20161124091800.14160-1-jslaby@suse.cz>
 <20161124091800.14160-11-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jiri Slaby' <jslaby@suse.cz>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:61823 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941049AbcKXMvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 07:51:13 -0500
In-Reply-To: <20161124091800.14160-11-jslaby@suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby
> Sent: 24 November 2016 09:18
> This patch has been added to the 3.12 stable tree. If you have any
> objections, please let us know.
> 
> ===============
> 
> [ Upstream commit a4b8e71b05c27bae6bad3bdecddbc6b68a3ad8cf ]
> 
> Most of getsockopt handlers in net/sctp/socket.c check len against
> sizeof some structure like:
>         if (len < sizeof(int))
>                 return -EINVAL;
> 
> On the first look, the check seems to be correct. But since len is int
> and sizeof returns size_t, int gets promoted to unsigned size_t too. So
> the test returns false for negative lengths. Yes, (-1 < sizeof(long)) is
> false.

Would it be worth adding the check in the generic setsockopt/getsockopt system
call code instead of in each and every protocol?
(Clearly for net-next, not stable.)

	David
