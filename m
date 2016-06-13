From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: prio: rollback allocations if prio_init() fails
Date: Mon, 13 Jun 2016 09:28:48 -0700
Message-ID: <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com> <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35224 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965049AbcFMQ3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:29:09 -0400
Received: by mail-yw0-f176.google.com with SMTP id z186so112447519ywd.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 09:29:08 -0700 (PDT)
In-Reply-To: <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 10:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Now prio_init() can return -ENOMEM, it also has to make sure
> any allocated qdisc are freed, since the caller (qdisc_create()) wont
> call ->destroy() handler for us.


But prio_tune() is called by ->change() too, so just call prio_destroy()
inside prio_tune() ?
