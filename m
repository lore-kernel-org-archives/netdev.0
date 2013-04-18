From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCHv2 0/5] bonding: enslave and locking bug fixes
Date: Thu, 18 Apr 2013 11:58:06 -0700
Message-ID: <15895.1366311486@death.nxdomain>
References: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:35505 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab3DRS6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 14:58:40 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 18 Apr 2013 14:58:38 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 034676E805D
	for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 14:58:32 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3IIwT3k292814
	for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 14:58:29 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3IIw708011009
	for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 15:58:08 -0300
In-reply-to: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>Hi,
>This patch-set fixes mainly bugs on enslave failure and one occasion
>of a needed locking. The patches are:
>
>	1. On enslave failure mc addresses are not flushed from the slave
>	2. On enslave failure vlans are not cleaned up from the slave
>	3. On enslave failure the bond's primary and curr_active_slave
>	   are not cleaned up (which might result in use of freed memory)
>	4. On enslave failure netpoll is not disabled which might result in
>	   a memory leak
>	5. In bond_mc_swap() the bond's mc addr list is walked without
>	   netif_addr_lock, since it can be called without rtnl, add it
>
>v2: patch 01 - fix log message and remove unnecessary code move

	All look good to me.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

>Best regards,
> Nik
>
>Nikolay Aleksandrov (5):
>  bonding: mc addresses don't get deleted on enslave failure
>  bonding: vlans don't get deleted on enslave failure
>  bonding: primary_slave & curr_active_slave are not cleaned on enslave
>    failure
>  bonding: disable netpoll on enslave failure
>  bonding: in bond_mc_swap() bond's mc addr list is walked without lock
>
> drivers/net/bonding/bond_main.c | 27 +++++++++++++++++++++++----
> 1 file changed, 23 insertions(+), 4 deletions(-)
>
>-- 
>1.8.1.4
>
