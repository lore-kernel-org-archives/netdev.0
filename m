From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net:switchdev: fix to release the lock before function
 return to avoid deadlock
Date: Tue, 6 Dec 2016 13:29:31 +0100
Message-ID: <20161206122931.GJ1984@nanopsycho>
References: <1481018964-47554-1-git-send-email-feng.deng@cortina-access.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, cxdx2006@gmail.com
To: Feng Deng <feng.deng@cortina-access.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33995 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbcLFM3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:29:34 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so21239484wme.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 04:29:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481018964-47554-1-git-send-email-feng.deng@cortina-access.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 06, 2016 at 11:09:24AM CET, feng.deng@cortina-access.com wrote:
>before switchdev_deferred_dequeue() normal return,show release the lock,
>if not,maybe there will be deadlock sometimes
>
>Signed-off-by: Feng Deng <feng.deng@cortina-access.com>
>---
> net/switchdev/switchdev.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 3b95fe9..c0a1ad4 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -120,6 +120,7 @@ static struct switchdev_deferred_item *switchdev_deferred_dequeue(void)
> 	dfitem = list_first_entry(&deferred,
> 				  struct switchdev_deferred_item, list);
> 	list_del(&dfitem->list);
>+	spin_unlock_bh(&deferred_lock);
> unlock:
> 	spin_unlock_bh(&deferred_lock);

You are joking right?
