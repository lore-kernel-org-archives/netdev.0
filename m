From: Paul Menage <menage@google.com>
Subject: Re: [PATCH] cls_cgroup: remove unneeded cgroup_lock
Date: Wed, 11 Mar 2009 19:41:06 -0700
Message-ID: <6599ad830903111941n5f244bb1n6d4df9268fe18fcb@mail.gmail.com>
References: <49B869B2.1020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:50155 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbZCLClM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 22:41:12 -0400
In-Reply-To: <49B869B2.1020303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 6:47 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> We can remove this lock here, since we are in cgroup write handler
> and thus the cgrp is guaranteed to be valid, and no lock is needed
> when writing a u32 variable.

There's no guarantee that the group isn't dead, so we could be writing
into a value that's never going to be used again, but I guess that's
not really a big deal.

Acked-by: Paul Menage <menage@google.com>

>
> Signed-off-by: Li Zefan <lizf@cn.fujitsuc.com>
> ---
>  net/sched/cls_cgroup.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
>
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 91a3db4..1ab4542 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -62,13 +62,7 @@ static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
>
>  static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
>  {
> -       if (!cgroup_lock_live_group(cgrp))
> -               return -ENODEV;
> -
>        cgrp_cls_state(cgrp)->classid = (u32) value;
> -
> -       cgroup_unlock();
> -
>        return 0;
>  }
>
> --
> 1.5.4.rc3
>
>
