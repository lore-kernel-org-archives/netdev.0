From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 10:22:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0208271011040.27776-100000@orchestra.cs.caltech.edu>
References: <20020827142004.C4358@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: jamal <hadi@cyberus.ca>, "Xiaoliang (David) Wei" <weixl@caltech.edu>,
   Ben Greear <greearb@candelatech.com>, Cheng Hu <chenghu@cs.caltech.edu>,
   Steven Low <slow@cs.caltech.edu>, "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20020827142004.C4358@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi, Andi,

> Quick fix is to just use gettimeoffset in netif_rx again. Should
> be fine for you.

There doesn't appear to be a function called gettimeoffset in 2.4.18
anymore.  The closest I found was do_fast_gettimeoffset in
"arch/i386/kernel/time.c"  This appears to be the unlocked version that
you are referring to, except I can't tell why the higher 32 bits (edx) of
the timestamp isn't used.  (maybe the asm code takes care of it, but it seems
that the result is stored in edx so)

What you said about a light-weight gettime function makes sense.  For our
purpose of timing RTTs, any gettime function with a resolution higher than
1 ms will probably be enough.  The time doesn't need to be in exactly in sync
with the one obtained from the locking version of the gettime function.

Thanks,

Cheng
