From: Andrew Morton <akpm@digeo.com>
Subject: Re: timer oops still present in 2.5.41-mm2
Date: Fri, 11 Oct 2002 14:59:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA749D9.83047205@digeo.com>
References: <3DA74711.2050907@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@redhat.com>, lkml <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Hansen <haveblue@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Hansen wrote:
> 
> Ingo, I hate to keep giving you false hope that this is fixed.  But,
> remember this is just -mm2, so any current BK fixes that change it
> wouldn't be in here, including the keyboard timer fixes that you were
> talking about.
> 
> Andrew, I noticed that you picked up Ingo's timer fix in 2.5.41-mm2 as
> timer-tricks.patch.

No, that was random akpm hacks.  Ingo's fix is in Linus's tree.
And, hence, in -mm3.

>  Despite this, Specweb ran for about 10 minutes
> on, then failed with the oops below.  2.5.41, without Ingo's patch
> oopses in seconds.  It's very hard to get results out of Specweb when
> it is crashing this often.
> 
> Could a misbehaving timer be causing the TCP errors too?  I'd never
> seen them before 2.5.40.  I don't know how closely the TCP errors
> occurred to the timer oops.
> 
> Attempt to release TCP socket in state 1 e099ed60
> Attempt to release TCP socket in state 1 f58cf460
> Attempt to release TCP socket in state 1 e0f7d5a0
> Attempt to release TCP socket in state 1 e106c4e0
> Attempt to release TCP socket in state 1 e02667e0

Well it could be that TCP is abusing the timer code.  It would be
sad if we were looking in the wrong place.  Might be a timing problem
in networking which has been exposed by smptimers.

Have you tried enabling all the memory debugging options?  It'll
cripple performance, but may help find something.
