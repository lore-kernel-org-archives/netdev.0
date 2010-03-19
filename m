From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] net: rtnetlink: ignore NETDEV_PRE_TYPE_CHANGE in
 rtnetlink_event()
Date: Fri, 19 Mar 2010 15:47:08 +0100
Message-ID: <20100319144707.GD2811@psychotron.redhat.com>
References: <4BA38D50.4090909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61923 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab0CSOrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 10:47:14 -0400
Content-Disposition: inline
In-Reply-To: <4BA38D50.4090909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 19, 2010 at 03:42:24PM CET, kaber@trash.net wrote:
>

>Ignore the new NETDEV_PRE_TYPE_CHANGE event in rtnetlink_event() since
>there have been no changes userspace needs to be notified of.
>
>Also add a comment to the netdev notifier event definitions to remind
>people to update the exclusion list when adding new event types.

Hmm, didn't have a clue this is needed. Anyway, original
"NETDEV_BONDING_OLDTYPE" and "NETDEV_BONDING_NEWTYPE" weren't here either.
Also you might want to add "NETDEV_POST_TYPE_CHANGE".

Jirka

>
>Signed-off-by: Patrick McHardy <kaber@trash.net>
>---
> include/linux/notifier.h |    5 ++++-
> net/core/rtnetlink.c     |    1 +
> 2 files changed, 5 insertions(+), 1 deletions(-)
>
>diff --git a/include/linux/notifier.h b/include/linux/notifier.h
>index f3635fc..9c5d3fa 100644
>--- a/include/linux/notifier.h
>+++ b/include/linux/notifier.h
>@@ -182,7 +182,10 @@ static inline int notifier_to_errno(int ret)
>  *	VC switch chains (for loadable kernel svgalib VC switch helpers) etc...
>  */
>  
>-/* netdevice notifier chain */
>+/* netdevice notifier chain. Please remember to update the rtnetlink
>+ * notification exclusion list in rtnetlink_event() when adding new
>+ * types.
>+ */
> #define NETDEV_UP	0x0001	/* For now you can't veto a device up/down */
> #define NETDEV_DOWN	0x0002
> #define NETDEV_REBOOT	0x0003	/* Tell a protocol stack a network interface
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index e1121f0..ffc6cf3 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -1513,6 +1513,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
> 	case NETDEV_POST_INIT:
> 	case NETDEV_REGISTER:
> 	case NETDEV_CHANGE:
>+	case NETDEV_PRE_TYPE_CHANGE:
> 	case NETDEV_GOING_DOWN:
> 	case NETDEV_UNREGISTER:
> 	case NETDEV_UNREGISTER_BATCH:
>-- 
>1.6.5.7
>

