From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6 net-next] inet: kill smallest_size and smallest_port
Date: Thu, 22 Dec 2016 14:41:51 -0800
Message-ID: <1482446511.8944.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
         <1482441998-28359-4-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
        kraigatgoog@gmail.com, tom@herbertland.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33601 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752729AbcLVWlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 17:41:53 -0500
Received: by mail-pf0-f194.google.com with SMTP id 127so2959374pfg.0
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 14:41:53 -0800 (PST)
In-Reply-To: <1482441998-28359-4-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-22 at 16:26 -0500, Josef Bacik wrote:
> In inet_csk_get_port we seem to be using smallest_port to figure out where the
> best place to look for a SO_REUSEPORT sk that matches with an existing set of
> SO_REUSEPORT's.  However if we get to the logic
> 
> if (smallest_size != -1) {
> 	port = smallest_port;
> 	goto have_port;
> }
> 
> we will do a useless search, because we would have already done the
> inet_csk_bind_conflict for that port and it would have returned 1, otherwise we
> would have gone to found_tb and succeeded.  Since this logic makes us do yet
> another trip through inet_csk_bind_conflict for a port we know won't work just
> delete this code and save us the time.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Please remove tb->need_owners ;)
