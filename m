From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net v3 3/3] net_sched: carefully handle tcf_block_put()
Date: Tue, 12 Sep 2017 12:43:58 +0200
Message-ID: <20170912104358.GG2036@nanopsycho>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170911233332.7594-4-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        jakub.kicinski@netronome.com, jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34926 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751370AbdILKoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 06:44:01 -0400
Received: by mail-wr0-f195.google.com with SMTP id n64so5815161wrb.2
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 03:44:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170911233332.7594-4-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 12, 2017 at 01:33:32AM CEST, xiyou.wangcong@gmail.com wrote:
>As pointed out by Jiri, there is still a race condition between
>tcf_block_put() and tcf_chain_destroy() in a RCU callback. There
>is no way to make it correct without proper locking or synchronization,
>because both operate on a shared list.
>
>Locking is hard, because the only lock we can pick here is a spinlock,
>however, in tc_dump_tfilter() we iterate this list with a sleeping
>function called (tcf_chain_dump()), which makes using a lock to protect
>chain_list almost impossible.
>
>Jiri suggested the idea of holding a refcnt before flushing, this works
>because it guarantees us there would be no parallel tcf_chain_destroy()
>during the loop, therefore the race condition is gone. But we have to
>be very careful with proper synchronization with RCU callbacks.
>
>Suggested-by: Jiri Pirko <jiri@mellanox.com>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks!
