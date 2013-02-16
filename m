From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v2] netpoll: add some missing __rcu marks in
 several places
Date: Fri, 15 Feb 2013 20:10:23 -0800
Message-ID: <1360987823.19353.42.camel@edumazet-glaptop>
References: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
	 <1360831039-11418-1-git-send-email-amwang@redhat.com>
	 <20130214.132054.2237485951582283881.davem@davemloft.net>
	 <1360984587.12539.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jiri@resnulli.us, vyasevic@redhat.com, stephen@networkplumber.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:40890 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab3BPEK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 23:10:26 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so2053138pad.9
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 20:10:26 -0800 (PST)
In-Reply-To: <1360984587.12539.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 11:16 +0800, Cong Wang wrote:

> The reason is we don't dereference ->npinfo pointer, we just check if it
> is NULL, so doesn't need to call rcu_dereference(). Or am I missing
> anything?

Yes you are missing that the right thing to do is to use
rcu_access_pointer()

Sparse errors should not be fixed using random RCU verbs,
please be more careful.


diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 05c5efe..03e5949 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -950,7 +950,7 @@ static void team_port_disable_netpoll(struct team_port *port)
 
 static struct netpoll_info *team_netpoll_info(struct team *team)
 {
-	return team->dev->npinfo;
+	return rcu_access_pointer(team->dev->npinfo);
 }
 
 #else
