From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/2] team: fix memory leak
Date: Mon, 24 Apr 2017 07:40:48 +0200
Message-ID: <20170424054048.GA1886@nanopsycho.orion>
References: <1492932564-722-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35196 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1046165AbdDXFkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 01:40:52 -0400
Received: by mail-wr0-f193.google.com with SMTP id g12so1070772wrg.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 22:40:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492932564-722-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Apr 23, 2017 at 09:29:24AM CEST, bianpan2016@163.com wrote:
>In function team_nl_send_port_list_get(), pointer skb keeps the return
>value of nlmsg_new(). When the call to genlmsg_put() fails, the memory
>is not freed. This will result in a memory leak bug. This patch fixes
>it.
>


Looks good. Please adjust subject so the both patches have a specific
one. Also, please add "Fixes" tag (see git log for details).
Also, is is good to say which tree this patches are generated against
("-net")


>Signed-off-by: Pan Bian <bianpan2016@163.com>
>---
> drivers/net/team/team.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index f8c81f1..dd3a2e9 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -2634,8 +2634,10 @@ static int team_nl_send_port_list_get(struct team *team, u32 portid, u32 seq,
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
