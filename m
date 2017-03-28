From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] openvswitch: Fix refcount leak on force commit.
Date: Tue, 28 Mar 2017 12:26:02 -0700
Message-ID: <CAPWQB7Ei6KSn2kpxcaBuSqT3=1xrk3ADXKCRCx_6i4i2uh58uQ@mail.gmail.com>
References: <1490725526-21075-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pravin shelar <pshelar@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:53726 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755688AbdC1T02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 15:26:28 -0400
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 43FF7C5A61
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 21:26:26 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id vEwIACN548HQ for <netdev@vger.kernel.org>;
        Tue, 28 Mar 2017 21:26:24 +0200 (CEST)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id BF5BAC5A4E
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 21:26:24 +0200 (CEST)
Received: by mail-qk0-f182.google.com with SMTP id f11so74632544qkb.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 12:26:24 -0700 (PDT)
In-Reply-To: <1490725526-21075-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 March 2017 at 11:25, Jarno Rajahalme <jarno@ovn.org> wrote:
> The reference count held for skb needs to be released when the skb's
> nfct pointer is cleared regardless of if nf_ct_delete() is called or
> not.
>
> Failing to release the skb's reference cound led to deferred conntrack
> cleanup spinning forever within nf_conntrack_cleanup_net_list() when
> cleaning up a network namespace:
>
>    kworker/u16:0-19025 [004] 45981067.173642: sched_switch: kworker/u16:0:19025 [120] R ==> rcu_preempt:7 [120]
>    kworker/u16:0-19025 [004] 45981067.173651: kernel_stack: <stack trace>
> => ___preempt_schedule (ffffffffa001ed36)
> => _raw_spin_unlock_bh (ffffffffa0713290)
> => nf_ct_iterate_cleanup (ffffffffc00a4454)
> => nf_conntrack_cleanup_net_list (ffffffffc00a5e1e)
> => nf_conntrack_pernet_exit (ffffffffc00a63dd)
> => ops_exit_list.isra.1 (ffffffffa06075f3)
> => cleanup_net (ffffffffa0607df0)
> => process_one_work (ffffffffa0084c31)
> => worker_thread (ffffffffa008592b)
> => kthread (ffffffffa008bee2)
> => ret_from_fork (ffffffffa071b67c)
>
> Fixes: dd41d33f0b03 ("openvswitch: Add force commit.")
> Reported-by: Yang Song <yangsong@vmware.com>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Thanks for the fix.

Acked-by: Joe Stringer <joe@ovn.org>
