From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] team: bcast: convert return value of
 team_dev_queue_xmit() to bool correctly
Date: Wed, 21 Nov 2012 13:53:28 +0100
Message-ID: <20121121125328.GA6812@minipsycho.orion>
References: <1353501285-1340-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dan.carpenter@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50098 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869Ab2KUMxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:53:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so2250473eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 04:53:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1353501285-1340-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I forgot to mention this bug was introduced by:
team: add broadcast mode (5fc889911a99043a97da1daa0d010ad72cbc3042)

Wed, Nov 21, 2012 at 01:34:45PM CET, jiri@resnulli.us wrote:
>The thing is that team_dev_queue_xmit() returns NET_XMIT_* or -E*.
>bc_trasmit() should return true in case all went well. So use ! to get
>correct retval from team_dev_queue_xmit() result.
>This bug caused iface statistics to be badly computed.
>
>Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>---
> drivers/net/team/team_mode_broadcast.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
>index 9db0171..c5db428 100644
>--- a/drivers/net/team/team_mode_broadcast.c
>+++ b/drivers/net/team/team_mode_broadcast.c
>@@ -29,8 +29,8 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
> 			if (last) {
> 				skb2 = skb_clone(skb, GFP_ATOMIC);
> 				if (skb2) {
>-					ret = team_dev_queue_xmit(team, last,
>-								  skb2);
>+					ret = !team_dev_queue_xmit(team, last,
>+								   skb2);
> 					if (!sum_ret)
> 						sum_ret = ret;
> 				}
>@@ -39,7 +39,7 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
> 		}
> 	}
> 	if (last) {
>-		ret = team_dev_queue_xmit(team, last, skb);
>+		ret = !team_dev_queue_xmit(team, last, skb);
> 		if (!sum_ret)
> 			sum_ret = ret;
> 	}
>-- 
>1.8.0
>
