From: "Mohd. Mohtashim" <mcmohd@rediffmail.com>
Subject: Re: Re: packet re-ordering on SMP machines.
Date: 27 Aug 2002 13:57:27 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020827135727.17673.qmail@webmail15.rediffmail.com>
Reply-To: "Mohd. Mohtashim" <mcmohd@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Cc: "Xiaoliang\(David\)Wei" <weixl@caltech.edu>,
   "Ben Greear" <greearb@candelatech.com>,
   "Cheng Jin" <chengjin@cs.caltech.edu>, "Cheng Hu" <chenghu@cs.caltech.edu>,
   "Steven Low" <slow@cs.caltech.edu>, netdev@oss.sgi.com,
   "jamal" <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Andi Kleen" <ak@suse.de>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Tue, 27 Aug 2002 Andi Kleen wrote :
>
>On Tue, Aug 27, 2002 at 08:05:04AM -0400, jamal wrote:
> >
> >
> >
> > On Tue, 27 Aug 2002, Andi Kleen wrote:
> >
> > >
> > > That is because of the lock it takes. Locks are always 
>slow.
> >
> > xtime_lock?
>
>Yes.
>
>It also has some other overhead.
>
> >
> > >
> > > Older kernels used gettimeoffset which ran without lock, but 
>that was
> > > changed because in some very obscure cases it could cause 
>non monotonous
> > > timestamps when the user turns on timestamp receiving to 
>user space
> > > (kernel protocols do not care)
> > >
> > > Possibilities:
> > >
> > > - Ignore the problem and switch back to gettimeoffset 
>again
> >
> > Is it safe to call gettimeoffset without the lock?
>
>
>Of course. The only problem is that the clock can be non 
>mononotonous
>sometimes and not be in sync with gettimeofday, but at least the 
>kernel
>users of packet timestamps do not care.
>The only problem is the socket option, but it is obscure enough 
>that I
>would not worry too much about it.
> >
> > > - Switch to gettimeoffset but add some correction step for 
>the unlikely
> > > case that someone wants the timestamp from user space
> > > (would be my prefered solution)
> > > - Implement lockless gettimeofday like x86-64 or sparc
> > > (good one too, but likely slower than last)
> >
> >
> > ia64 seems to also have the lock.
>
>Quick fix is to just use gettimeoffset in netif_rx again. 
>Should
>be fine for you.
>
>-Andi
>
