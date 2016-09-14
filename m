From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 18:18:37 -0700
Message-ID: <1473815917.18970.266.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
         <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
         <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32964 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752686AbcINBSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 21:18:40 -0400
Received: by mail-pa0-f48.google.com with SMTP id cm16so1029016pac.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 18:18:40 -0700 (PDT)
In-Reply-To: <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-13 at 17:23 -0700, Michael Ma wrote:

> If I understand correctly this is still to associate a qdisc with each
> ifb TXQ. How should I do this if I want to use HTB? I guess I'll need
> to divide the bandwidth of each class in HTB by the number of TX
> queues for each individual HTB qdisc associated?
> 
> My original idea was to attach a HTB qdisc for each ifb queue
> representing a set of flows not sharing bandwidth with others so that
> root lock contention still happens but only affects flows in the same
> HTB. Did I understand the root lock contention issue incorrectly for
> ifb? I do see some comments in __dev_queue_xmit() about using a
> different code path for software devices which bypasses
> __dev_xmit_skb(). Does this mean ifb won't go through
> __dev_xmit_skb()?

You can install HTB on all of your MQ children for sure.

Again, there is no qdisc lock contention if you properly use MQ.

Now if you _need_ to install a single qdisc for whatever reason, then
maybe you want to use a single rx queue on the NIC, to reduce lock
contention ;)
