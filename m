From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] net: check for NULL net_device in FIB tables
Date: Mon, 4 Jul 2016 15:50:23 +0200
Message-ID: <577A699F.9030909@oracle.com>
References: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35840 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbcGDNub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:50:31 -0400
In-Reply-To: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2016 02:47 PM, Vegard Nossum wrote:
> struct fib_nh->nh_dev can be NULL, so we should check it before calling
> __in_dev_get_rcu on it.

That should say __in_dev_get_rtnl(), obviously.

>
> Multiple places seem to want this (and check the return value), so we can
> add a convenience wrapper for this.
>
> This fixes a crash in AF_NETLINK sendmsg().
>
> Please double check that I caught all the callers that need the NULL
> guard.
>
> Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Cc: Dinesh Dutt <ddutt@cumulusnetworks.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

I guess we could also add:

Cc: stable@vger.kernel.org


Vegard
