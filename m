From: Andi Kleen <ak@suse.de>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 19:33:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020827193303.B4971@wotan.suse.de>
References: <20020827142004.C4358@wotan.suse.de> <Pine.LNX.4.33L0.0208271011040.27776-100000@orchestra.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: Andi Kleen <ak@suse.de>, jamal <hadi@cyberus.ca>,
   "Xiaoliang (David) Wei" <weixl@caltech.edu>,
   Ben Greear <greearb@candelatech.com>, Cheng Hu <chenghu@cs.caltech.edu>,
   Steven Low <slow@cs.caltech.edu>, "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L0.0208271011040.27776-100000@orchestra.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, Aug 27, 2002 at 10:22:13AM -0700, Cheng Jin wrote:
> Hi, Andi,
> 
> > Quick fix is to just use gettimeoffset in netif_rx again. Should
> > be fine for you.
> 
> There doesn't appear to be a function called gettimeoffset in 2.4.18
> anymore.  The closest I found was do_fast_gettimeoffset in
> "arch/i386/kernel/time.c"  This appears to be the unlocked version that

Yes, I mean do_fast_gettimeoffset.
> you are referring to, except I can't tell why the higher 32 bits (edx) of
> the timestamp isn't used.  (maybe the asm code takes care of it, but it seems
> that the result is stored in edx so)

32bit precision are probably enough for this.

> 
> What you said about a light-weight gettime function makes sense.  For our
> purpose of timing RTTs, any gettime function with a resolution higher than
> 1 ms will probably be enough.  The time doesn't need to be in exactly in sync
> with the one obtained from the locking version of the gettime function.

TSC should be fine then.

-Andi
