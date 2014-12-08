From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] netlink: IFLA_PHYS_SWITCH_ID to
 IFLA_PHYS_PARENT_ID
Date: Mon, 8 Dec 2014 17:41:43 +0100
Message-ID: <20141208164143.GI1885@nanopsycho.brq.redhat.com>
References: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
 <1417802537-20020-2-git-send-email-gospo@cumulusnetworks.com>
 <20141208151714.GG1885@nanopsycho.brq.redhat.com>
 <20141208153747.GG797@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:59567 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbaLHQlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:41:46 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so6656627wgh.20
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 08:41:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141208153747.GG797@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 08, 2014 at 04:37:47PM CET, gospo@cumulusnetworks.com wrote:
>On Mon, Dec 08, 2014 at 04:17:14PM +0100, Jiri Pirko wrote:
>> Fri, Dec 05, 2014 at 07:02:16PM CET, gospo@cumulusnetworks.com wrote:
>> >There has been much discussion about proper nomenclature to use for this
>> >and I would prefer parent rather than calling every forwarding element a
>> >switch.
>> 
>> Andy, I must say I really do not like just plain "parent". It is really
>> not clear what it means as it can mean 1000 things.
>> 
>> I know "switch" is not ideal but everytime anyone is talking about these
>> kind of forwarding devices, they use word "switch" even if it is not
>> accurate and everyone knows what they are talking about. Nobody uses
>> "parent".
>
>Well of course they are not going to use it until it's committed.  ;-)


Do you seriously expect people talking about "parents" instead of
"switches". I doubt that...

>
>> For me this is nack for this patchset.
>
>Thanks for the review.  I am not big marketing person, so it was not
>clear to me what was ideal.  Due to parent already being in the code
>and having as a logical description of the relationship (parent
>switch/router device and sibling network interfaces -- like sibling CPU
>cores on the same socket).
>
>I do really want to collectively come up with something other than
>switch for everything.  Those L3 ops with 'switch' in the name will
>feel really awkward....


I say it is not optimal, but I did not see any better proposal...


>
>> 
>> Jiri
>> 
>> >
>> >Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> >---
>> > include/uapi/linux/if_link.h | 2 +-
>> > net/core/rtnetlink.c         | 4 ++--
>> > 2 files changed, 3 insertions(+), 3 deletions(-)
>> >
>> >diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> >index f7d0d2d..3d8edd8 100644
>> >--- a/include/uapi/linux/if_link.h
>> >+++ b/include/uapi/linux/if_link.h
>> >@@ -145,7 +145,7 @@ enum {
>> > 	IFLA_CARRIER,
>> > 	IFLA_PHYS_PORT_ID,
>> > 	IFLA_CARRIER_CHANGES,
>> >-	IFLA_PHYS_SWITCH_ID,
>> >+	IFLA_PHYS_PARENT_ID,
>> > 	__IFLA_MAX
>> > };
>> > 
>> >diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> >index 61cb7e7..1fe0a16 100644
>> >--- a/net/core/rtnetlink.c
>> >+++ b/net/core/rtnetlink.c
>> >@@ -982,7 +982,7 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
>> > 		return err;
>> > 	}
>> > 
>> >-	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, psid.id_len, psid.id))
>> >+	if (nla_put(skb, IFLA_PHYS_PARENT_ID, psid.id_len, psid.id))
>> > 		return -EMSGSIZE;
>> > 
>> > 	return 0;
>> >@@ -1222,7 +1222,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>> > 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
>> > 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>> > 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
>> >-	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>> >+	[IFLA_PHYS_PARENT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>> > };
>> > 
>> > static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
>> >-- 
>> >1.9.3
>> >
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
