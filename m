From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: net: BUG still has locks held in unix_stream_splice_read
Date: Mon, 10 Oct 2016 03:46:07 +0100
Message-ID: <20161010024607.GV19539@ZenIV.linux.org.uk>
References: <CACT4Y+aPybMnXjiH+DdDWDAfz+L6PF-H-J3YT2+hjcDp3aw9SQ@mail.gmail.com>
 <CACT4Y+a6yDm28VYtNPSktYKs_T2UzLGb8jadpFpsdKfNzb7-tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+a6yDm28VYtNPSktYKs_T2UzLGb8jadpFpsdKfNzb7-tA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 09, 2016 at 12:06:14PM +0200, Dmitry Vyukov wrote:
> I suspect this is:
> 
> commit 25869262ef7af24ccde988867ac3eb1c3d4b88d4
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Sat Sep 17 21:02:10 2016 -0400
>     skb_splice_bits(): get rid of callback
>     since pipe_lock is the outermost now, we don't need to drop/regain
>     socket locks around the call of splice_to_pipe() from skb_splice_bits(),
>     which kills the need to have a socket-specific callback; we can just
>     call splice_to_pipe() and be done with that.

Unlikely, since that particular commit removes unlocking/relocking ->iolock
around the call of splice_to_pipe().  Original would've retaken the same
lock on the way out; it's not as if we could leave the syscall there.

It might be splice-related, but I don't believe that you've got the right
commit here.
