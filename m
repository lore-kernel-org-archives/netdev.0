From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: don't permit slaves to change their mtu
Date: Tue, 14 Jan 2014 07:15:56 +0100
Message-ID: <20140114061556.GA7798@redhat.com>
References: <52D4A8A7.60100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbaANGTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:19:00 -0500
Content-Disposition: inline
In-Reply-To: <52D4A8A7.60100@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 11:01:59AM +0800, Ding Tianhong wrote:
>The commit 2315dc91a5059d7da9a8b9b9daf78d695c11383e
>(net: make dev_set_mtu() honor notification return code)
>will deal with the return value for NETDEV_CHANGEMTU notification,
>and the slaves should not change their mtu, so add return value
>to prevent doing it.

In another email you said you've tested the mtu changes and some of the
bonds have packet loss when mtu is changed, and some of them don't.

Maybe it'd be good to understand which modes can tolerate the mtu change
(if it can be tolerated at all/if it should really matter) and allow it for
specific bond modes only/for any bond modes?

>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>

Don't add my name unless I specifically ask you to, please.

Thank you.

>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 16 ++++------------
> 1 file changed, 4 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e06c445..af4e678 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2846,19 +2846,11 @@ static int bond_slave_netdev_event(unsigned long event,
> 		 */
> 		break;
> 	case NETDEV_CHANGEMTU:
>-		/*
>-		 * TODO: Should slaves be allowed to
>-		 * independently alter their MTU?  For
>-		 * an active-backup bond, slaves need
>-		 * not be the same type of device, so
>-		 * MTUs may vary.  For other modes,
>-		 * slaves arguably should have the
>-		 * same MTUs. To do this, we'd need to
>-		 * take over the slave's change_mtu
>-		 * function for the duration of their
>-		 * servitude.
>+		/* The master and slaves should have the
>+		 * the same mtu, so do't permit slaves
>+		 * to change their mtu independently.
> 		 */
>-		break;
>+		return NOTIFY_BAD;
> 	case NETDEV_CHANGENAME:
> 		/*
> 		 * TODO: handle changing the primary's name
>-- 
>1.8.0
>
>
