From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 1/1] net sched filters: fix notification of
 filter delete with proper handle
Date: Thu, 27 Oct 2016 17:12:56 -0400 (EDT)
Message-ID: <20161027.171256.1801600228800981297.davem@davemloft.net>
References: <1477354707-7210-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com, jiri@resnulli.us
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964799AbcJ0VNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 17:13:00 -0400
In-Reply-To: <1477354707-7210-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 24 Oct 2016 20:18:27 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Daniel says:
> 
> While trying out [1][2], I noticed that tc monitor doesn't show the
> correct handle on delete:
> 
> $ tc monitor
> qdisc clsact ffff: dev eno1 parent ffff:fff1
> filter dev eno1 ingress protocol all pref 49152 bpf handle 0x2a [...]
> deleted filter dev eno1 ingress protocol all pref 49152 bpf handle 0xf3be0c80
> 
> some context to explain the above:
> The user identity of any tc filter is represented by a 32-bit
> identifier encoded in tcm->tcm_handle. Example 0x2a in the bpf filter
> above. A user wishing to delete, get or even modify a specific filter
> uses this handle to reference it.
> Every classifier is free to provide its own semantics for the 32 bit handle.
> Example: classifiers like u32 use schemes like 800:1:801 to describe
> the semantics of their filters represented as hash table, bucket and
> node ids etc.
> Classifiers also have internal per-filter representation which is different
> from this externally visible identity. Most classifiers set this
> internal representation to be a pointer address (which allows fast retrieval
> of said filters in their implementations). This internal representation
> is referenced with the "fh" variable in the kernel control code.
> 
> When a user successfuly deletes a specific filter, by specifying the correct
> tcm->tcm_handle, an event is generated to user space which indicates
> which specific filter was deleted.
> 
> Before this patch, the "fh" value was sent to user space as the identity.
> As an example what is shown in the sample bpf filter delete event above
> is 0xf3be0c80. This is infact a 32-bit truncation of 0xffff8807f3be0c80
> which happens to be a 64-bit memory address of the internal filter
> representation (address of the corresponding filter's struct cls_bpf_prog);
> 
> After this patch the appropriate user identifiable handle as encoded
> in the originating request tcm->tcm_handle is generated in the event.
> One of the cardinal rules of netlink rules is to be able to take an
> event (such as a delete in this case) and reflect it back to the
> kernel and successfully delete the filter. This patch achieves that.
> 
> Note, this issue has existed since the original TC action
> infrastructure code patch back in 2004 as found in:
> https://git.kernel.org/cgit/linux/kernel/git/history/history.git/commit/
> 
> [1] http://patchwork.ozlabs.org/patch/682828/
> [2] http://patchwork.ozlabs.org/patch/682829/
> 
> Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied and queued up for -stable, thanks Jamal.
