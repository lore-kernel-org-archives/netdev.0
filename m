From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 3/4] net_sched: remove tc class reference
 counting
Date: Fri, 25 Aug 2017 08:28:55 -0400
Message-ID: <4892b5e7-2734-c717-ea04-1109d43b9011@mojatatu.com>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-4-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36988 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755854AbdHYM27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 08:28:59 -0400
Received: by mail-io0-f195.google.com with SMTP id j99so1238914ioo.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 05:28:59 -0700 (PDT)
In-Reply-To: <20170824235130.28503-4-xiyou.wangcong@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-24 07:51 PM, Cong Wang wrote:
> For TC classes, their ->get() and ->put() are always paired, and the
> reference counting is completely useless, because:
> 
> 1) For class modification and dumping paths, we already hold RTNL lock,
>     so all of these ->get(),->change(),->put() are atomic.
> 
> 2) For filter bindiing/unbinding, we use other reference counter than
>     this one, and they should have RTNL lock too.
> 
> 3) For ->qlen_notify(), it is special because it is called on ->enqueue()
>     path, but we already hold qdisc tree lock there, and we hold this
>     tree lock when graft or delete the class too, so it should not be gone
>     or changed until we release the tree lock.
> 
> Therefore, this patch removes ->get() and ->put(), but:
> 
> 1) Adds a new ->find() to find the pointer to a class by classid, no
>     refcnt.
> 
> 2) Move the original class destroy upon the last refcnt into ->delete(),
>     right after releasing tree lock. This is fine because the class is
>     already removed from hash when holding the lock.
> 
> For those who also use ->put() as ->unbind(), just rename them to reflect
> this change.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I am a tiny bit worried about this - but i went over it and it looks
good. I cant think of any use cases where something may fall out, so:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
