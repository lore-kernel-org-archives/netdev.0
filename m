From: jamal <hadi@cyberus.ca>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 08:05:04 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208270803520.6895-100000@shell.cyberus.ca>
References: <20020827131227.A16565@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: "Xiaoliang (David) Wei" <weixl@caltech.edu>,
   Ben Greear <greearb@candelatech.com>, Cheng Jin <chengjin@cs.caltech.edu>,
   Cheng Hu <chenghu@cs.caltech.edu>, Steven Low <slow@cs.caltech.edu>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20020827131227.A16565@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





On Tue, 27 Aug 2002, Andi Kleen wrote:

>
> That is because of the lock it takes. Locks are always slow.

xtime_lock?

>
> Older kernels used gettimeoffset which ran without lock, but that was
> changed because in some very obscure cases it could cause non monotonous
> timestamps when the user turns on timestamp receiving to user space
> (kernel protocols do not care)
>
> Possibilities:
>
> - Ignore the problem and switch back to gettimeoffset again

Is it safe to call gettimeoffset without the lock?

> - Switch to gettimeoffset but add some correction step for the unlikely
> case that someone wants the timestamp from user space
> (would be my prefered solution)
> - Implement lockless gettimeofday like x86-64 or sparc
> (good one too, but likely slower than last)


ia64 seems to also have the lock.

cheers,
jamal
