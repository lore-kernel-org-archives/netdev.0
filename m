From: Blaschka <frank.blaschka@de.ibm.com>
Subject: Re: -next Mar 22: s390 build failure (drivers/s390/net/qeth_l3)
Date: Mon, 22 Mar 2010 14:00:25 +0100
Message-ID: <20100322130025.GA8558@tuxmaker.boeblingen.de.ibm.com>
References: <20100322171937.d753bdba.sfr@canb.auug.org.au> <4BA73423.6080101@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	davem@davemloft.net
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:55271 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab0CVNA1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 09:00:27 -0400
Content-Disposition: inline
In-Reply-To: <4BA73423.6080101@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 22, 2010 at 02:40:59PM +0530, Sachin Sant wrote:
> Todays next fails to build on a s390 box with
> 
>  CC [M]  drivers/s390/net/qeth_l3_main.o
> drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_free_vlan_addresses6':
> drivers/s390/net/qeth_l3_main.c:1931: error: incompatible types in 
> assignment
> drivers/s390/net/qeth_l3_main.c:1931: error: 'struct inet6_ifaddr' has no 
> member named 'lst_next'
> make[2]: *** [drivers/s390/net/qeth_l3_main.o] Error 1
>

Hi, this patch should fix the problem

Thanks
	Frank

--- 
[PATCH] qeth: l3 fix build error in ipv6 addr list handling

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Adapt qeth l3 to:
commit c2e21293c054817c42eb5fa9c613d2ad51954136
(ipv6: convert addrconf list to hlist)
converted lst_next member of inet6_ifaddr struct to a hlist.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1928,7 +1928,7 @@ static void qeth_l3_free_vlan_addresses6
 	in6_dev = in6_dev_get(vlan_group_get_device(card->vlangrp, vid));
 	if (!in6_dev)
 		return;
-	for (ifa = in6_dev->addr_list; ifa; ifa = ifa->lst_next) {
+	list_for_each_entry(ifa, &in6_dev->addr_list, if_list) {
 		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
 		if (addr) {
 			memcpy(&addr->u.a6.addr, &ifa->addr,
