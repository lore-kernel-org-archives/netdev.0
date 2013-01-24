From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 16:23:51 -0800
Message-ID: <1358987031.12374.1276.camel@edumazet-glaptop>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>
	 <5100785D.8040101@candelatech.com>
	 <1358985688.12374.1247.camel@edumazet-glaptop>
	 <51007CA8.2050105@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51007CA8.2050105-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-23 at 16:13 -0800, Ben Greear wrote:
> On 01/23/2013 04:01 PM, Eric Dumazet wrote:
> > On Wed, 2013-01-23 at 15:55 -0800, Ben Greear wrote:
> >> On 01/22/2013 06:32 PM, Ben Greear wrote:
> >>
> >> So, I'm slowly making some progress.  I've verified that the skb
> >> has bogus dst (0xdeadbeef) at the top of the ip_rcv_finish
> >> method.  I'm trying to track it backwards and figure out which
> >> device it belongs to, etc....takes a while to reproduce though.
> >>
> >> One thing about this stack trace below...the dev_seq_stop() does
> >> a rcu read-unlock.  Now, I can't figure out exactly how ip_rcv()
> >> can cause dev_seq_stop() to run, but if this stack is legit,
> >> then maybe by the time we enter the ip_rcv_finish() code we are
> >> running without rcu_readlock() held?
> >>
> >> If so, that would probably explain the bug.
> >>
> >
> > The whole thing is run under rcu_read_lock() done in
> > __netif_receive_skb()
> 
> I was worried that the dev_seq_stop might be called
> incorrectly causing an asymetric unlock.  I have no
> idea how that might happened, but several crashes
> have that dev_seq_stop method listed, so it got me suspicious.

dev_seq_stop() is some word in the kernel stack, result of a prior
system call. Stack is not cleanup.

Each function reserves an amount of stack but not always write on all
reserved space (some automatic variables might be not set)

Note the "? " before the name : linux printed the symbol but this was
not a call site for this particular call graph. Its only an extra
indication, that can be useful sometimes.



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
