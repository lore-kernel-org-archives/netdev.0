From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netns: use a spin_lock to protect nsid management
Date: Tue, 12 May 2015 12:16:30 -0700
Message-ID: <CAM_iQpUSgpeL_Dy+U+KrBd=h3bhm03vASupdO-9dSs+CKYjNeg@mail.gmail.com>
References: <20150512175227.GA19020@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	kernel-janitors@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150512175227.GA19020@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Please always Cc netdev for networking bugs)

On Tue, May 12, 2015 at 10:52 AM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> Hello Nicolas Dichtel,
>
> The patch 95f38411df05: "netns: use a spin_lock to protect nsid
> management" from May 7, 2015, leads to the following static checker
> warning:
>
>         net/core/net_namespace.c:580 rtnl_net_newid()
>         warn: inconsistent returns 'spin_lock:&nsid_lock'.
>
> net/core/net_namespace.c
>    565
>    566          spin_lock_irqsave(&nsid_lock, flags);
>    567          if (__peernet2id(net, peer) >= 0) {
>    568                  err = -EEXIST;
>    569                  goto out;
>
> I don't know if __peernet2id() unlocks on error but it can't possibly
> restore flags so this isn't right.
>

Yes it is a bug.

Also why do we have to disable IRQ when holding the spinlock?
IOW, which case takes the spin lock in IRQ context?

Thanks.
