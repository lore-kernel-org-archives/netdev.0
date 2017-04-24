From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/2] net: team: fix memory leak in
 team_nl_send_options_get
Date: Mon, 24 Apr 2017 09:11:29 +0200
Message-ID: <20170424071129.GE1886@nanopsycho.orion>
References: <1493017495-3578-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33991 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165905AbdDXHLh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:11:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id z129so15123668wmb.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 00:11:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493017495-3578-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 24, 2017 at 09:04:55AM CEST, bianpan2016@163.com wrote:
>In function team_nl_send_options_get(), pointer skb keeps the return
>value of function nlmsg_new(). When the call to genlmsg_put() fails, the
>control flow directly returns and does not free skb. This will result in
>a memory leak bug. This patch fixes it.
>
>Fixes: 8ea7fd0d8792 ("team: fix memory leak")

test1:~/net-next$ git log 8ea7fd0d8792
fatal: ambiguous argument '8ea7fd0d8792': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'


Please look up the commit that introduces the issue. Also no newline
in between "fixes" and "signed off".

Also. The subject should be:
[PATCH net 2/2] team: fix memory leak in team_nl_send_options_get

You can see this right away if you look in the mailing list archive...



>
>Signed-off-by: Pan Bian <bianpan2016@163.com>
>---
> drivers/net/team/team.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index dd3a2e9..85c0124 100644
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
>-- 
>1.9.1
>
>
