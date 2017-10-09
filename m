From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 0/2] net: defer cgroups init to accept()
Date: Sun, 8 Oct 2017 21:47:49 -0700
Message-ID: <CANn89iKwxY8fiozVvRVhUTO14Cj_DBBoTHrEzYmPE2EwbZL8qw@mail.gmail.com>
References: <20171009044452.20564-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tejun Heo <tj@kernel.org>, John Sperbeck <jsperbeck@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:44986 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbdJIEru (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:47:50 -0400
Received: by mail-qt0-f170.google.com with SMTP id v28so32150214qtv.1
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:47:50 -0700 (PDT)
In-Reply-To: <20171009044452.20564-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 8, 2017 at 9:44 PM, Eric Dumazet <edumazet@google.com> wrote:
> After TCP 3WHS became lockless, we should not attempt cgroup games
> from sk_clone_lock() since listener/cgroup might be already gone.
>
> Move this business to inet_csk_accept() where we have
> the guarantee both parent and child exist.
>
> Many thanks to John Sperbeck for spotting these issues
>
> Eric Dumazet (2):
>   net: memcontrol: defer call to mem_cgroup_sk_alloc()
>   net: defer call to cgroup_sk_alloc()

This was based on net tree, but I used the wrong script, and thus this
has the [PATCH net-next] tag.

Sorry for the confusion, but I guess this also can be applied to
net-next since this is not a recent regression.
