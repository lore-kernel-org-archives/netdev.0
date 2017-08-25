From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v2 3/4] net_sched: remove tc class reference
 counting
Date: Fri, 25 Aug 2017 11:41:16 +0200
Message-ID: <20170825094116.GE2023@nanopsycho>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-4-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38844 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754938AbdHYJlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 05:41:19 -0400
Received: by mail-wr0-f196.google.com with SMTP id o76so760188wrb.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 02:41:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170824235130.28503-4-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 25, 2017 at 01:51:29AM CEST, xiyou.wangcong@gmail.com wrote:
>For TC classes, their ->get() and ->put() are always paired, and the
>reference counting is completely useless, because:
>
>1) For class modification and dumping paths, we already hold RTNL lock,
>   so all of these ->get(),->change(),->put() are atomic.
>
>2) For filter bindiing/unbinding, we use other reference counter than
>   this one, and they should have RTNL lock too.
>
>3) For ->qlen_notify(), it is special because it is called on ->enqueue()
>   path, but we already hold qdisc tree lock there, and we hold this
>   tree lock when graft or delete the class too, so it should not be gone
>   or changed until we release the tree lock.
>
>Therefore, this patch removes ->get() and ->put(), but:
>
>1) Adds a new ->find() to find the pointer to a class by classid, no
>   refcnt.
>
>2) Move the original class destroy upon the last refcnt into ->delete(),
>   right after releasing tree lock. This is fine because the class is
>   already removed from hash when holding the lock.
>
>For those who also use ->put() as ->unbind(), just rename them to reflect
>this change.
>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Look very nice. Thanks!
Acked-by: Jiri Pirko <jiri@mellanox.com>
