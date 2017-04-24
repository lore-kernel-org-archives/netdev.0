From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net 1/1] team: fix memory leaks
Date: Mon, 24 Apr 2017 11:42:31 +0200
Message-ID: <20170424094231.GC4126@nanopsycho.orion>
References: <1493026612-12383-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34049 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168080AbdDXJmi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 05:42:38 -0400
Received: by mail-wr0-f193.google.com with SMTP id 6so5838681wrb.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 02:42:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493026612-12383-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting. In last reply, I put the "[]" prefix example exactly as it
should be, yet you managed to have it wrong...


Mon, Apr 24, 2017 at 11:36:52AM CEST, bianpan2016@163.com wrote:
>In functions team_nl_send_port_list_get() and
>team_nl_send_options_get(), pointer skb keeps the return value of
>nlmsg_new(). When the call to genlmsg_put() fails, the memory is not
>freed(). This will result in memory leak bugs.
>
>Fixes: 9b00cf2d1024 ("team: implement multipart netlink messages for
>options transfers")

No linewraps here, please.



>Signed-off-by: Pan Bian <bianpan2016@163.com>
>---
> drivers/net/team/team.c | 8 ++++++--
> 1 file changed, 6 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index f8c81f1..85c0124 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -2361,8 +2361,10 @@ static int team_nl_send_options_get(struct team *team, u32 portid, u32 seq,
> 
> 	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags | NLM_F_MULTI,
> 			  TEAM_CMD_OPTIONS_GET);
>-	if (!hdr)
>+	if (!hdr) {
>+		nlmsg_free(skb);
> 		return -EMSGSIZE;
>+	}
> 
> 	if (nla_put_u32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex))
> 		goto nla_put_failure;
>@@ -2634,8 +2636,10 @@ static int team_nl_send_port_list_get(struct team *team, u32 portid, u32 seq,
> 
> 	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags | NLM_F_MULTI,
> 			  TEAM_CMD_PORT_LIST_GET);
>-	if (!hdr)
>+	if (!hdr) {
>+		nlmsg_free(skb);
> 		return -EMSGSIZE;
>+	}
> 
> 	if (nla_put_u32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex))
> 		goto nla_put_failure;
>-- 
>1.9.1
>
>
