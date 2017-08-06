From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: use __GFP_NOWARN for sctpw.fifo allocation
Date: Sun, 6 Aug 2017 20:39:27 -0300
Message-ID: <20170806233927.GB7613@localhost.localdomain>
References: <53b360387db05bf31db481234e7070e4a7ba6a25.1501936269.git.lucien.xin@gmail.com>
 <20170805170859.GA7613@localhost.localdomain>
 <CADvbK_f_q-gJHey9oUZUrxyGSYXasMVj0kqvhEkzDUPsGDzeng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>, Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60036 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751355AbdHFXjb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 6 Aug 2017 19:39:31 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_f_q-gJHey9oUZUrxyGSYXasMVj0kqvhEkzDUPsGDzeng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 06, 2017 at 06:14:39PM +1200, Xin Long wrote:
> On Sun, Aug 6, 2017 at 5:08 AM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > On Sat, Aug 05, 2017 at 08:31:09PM +0800, Xin Long wrote:
> >> Chen Wei found a kernel call trace when modprobe sctp_probe with
> >> bufsize set with a huge value.
> >>
> >> It's because in sctpprobe_init when alloc memory for sctpw.fifo,
> >> the size is got from userspace. If it is too large, kernel will
> >> fail and give a warning.
> >
> > Yes but sctp_probe can only be loaded by an admin and it would happen
> > only during modprobe. It's different from the commit mentioned below, on
> > which any user could trigger it.
> yeah, in this way it's different, I think generally it's acceptable to have
> this kinda warning call trace by admin.
> 
> But it could get the feedback from the return value and the warning
> call trace seems not useful. sometimes users may be confused

users or admins?

> with this call trace. So it may be better not to dump the warning ?
> 
> Or you think it can be helpful if we leave it here ?

I'm afraid we may be exagerating here. There are several other ways that
an admin can trigger scary warnings, this one is no special. I'd rather
leave this one to the mm defaults instead.

> 
> >
> >>
> >> As there will be a fallback allocation later, this patch is just
> >> to fail silently and return ret, just as commit 0ccc22f425e5
> >> ("sit: use __GFP_NOWARN for user controlled allocation") did.
> >>
> >> Reported-by: Chen Wei <weichen@redhat.com>
> >> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> >> ---
> >>  net/sctp/probe.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
> >> index 6cc2152..5bf3164 100644
> >> --- a/net/sctp/probe.c
> >> +++ b/net/sctp/probe.c
> >> @@ -210,7 +210,7 @@ static __init int sctpprobe_init(void)
> >>
> >>       init_waitqueue_head(&sctpw.wait);
> >>       spin_lock_init(&sctpw.lock);
> >> -     if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL))
> >> +     if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL | __GFP_NOWARN))
> >>               return ret;
> >>
> >>       if (!proc_create(procname, S_IRUSR, init_net.proc_net,
> >> --
> >> 2.1.0
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
