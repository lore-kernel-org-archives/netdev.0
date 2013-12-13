From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 0/3] bonding: add port protection for bond_3ad_xxx_change()
Date: Fri, 13 Dec 2013 14:26:02 -0800
Message-ID: <28416.1386973562@death.nxdomain>
References: <52AAD36B.40103@huawei.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:47542 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266Ab3LMW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 17:26:08 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 13 Dec 2013 15:26:08 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 11E023E40052
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 15:26:06 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBDMQ5m39372060
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 23:26:05 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rBDMT8Ac000739
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 15:29:08 -0700
In-reply-to: <52AAD36B.40103@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>Jay Vosburgh said that the bond_3ad_adapter_speed_changed and 
>bond_3ad_adapter_duplex_changed is called with RTNL only, and
>the functions will modify the port's information with no further
>locking, they will not mutex against bond state machine and
>incoming LACPDU which do not hold RTNL, So I add port lock to
>protect the port information.
>
>But they are not critical bugs, they exist since day one, and till
>now they have never been hit and reported, because change for speed
>and duplex is very rare, and will not occur critical problem.
>
>The comments in the function is very old, cleanup the comments together.

	For entire series:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

>Ding Tianhong (3):
>  bonding: protect port for bond_3ad_adapter_speed_changed()
>  bonding: protect port for bond_3ad_adapter_duplex_changed()
>  bonding: protect port for bond_3ad_handle_link_change()
>
> drivers/net/bonding/bond_3ad.c | 45 +++++++++++++++++++++++++++++++-----------
> 1 file changed, 33 insertions(+), 12 deletions(-)
>
>-- 
>1.8.0

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
