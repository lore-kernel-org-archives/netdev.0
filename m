From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: SPLICE_F_NONBLOCK semantics...
Date: Thu, 1 Oct 2009 15:21:44 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0910011516390.6996@localhost.localdomain>
References: <20091001.151102.09812927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, jgunthorpe@obsidianresearch.com,
	vl@samba.org, opurdila@ixiacom.com, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jens Axboe <jens.axboe@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753459AbZJAWW1@vger.kernel.org>
In-Reply-To: <20091001.151102.09812927.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 1 Oct 2009, David Miller wrote:
> 
> It depends upon our interpretation of how you intended the
> SPLICE_F_NONBLOCK flag to work when you added it way back
> when.
> 
> Linus introduced  SPLICE_F_NONBLOCK in commit 29e350944fdc2dfca102500790d8ad6d6ff4f69d
> (splice: add SPLICE_F_NONBLOCK flag )
> 
>   It doesn't make the splice itself necessarily nonblocking (because the
>   actual file descriptors that are spliced from/to may block unless they
>   have the O_NONBLOCK flag set), but it makes the splice pipe operations
>   nonblocking.
> 
> Linus intention was clear : let SPLICE_F_NONBLOCK control the splice pipe mode only

Ack. The original intent was for the flag to affect the buffering, not the 
end points.

> splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK ); 
> 
> to block on data coming from socket (if file is in blocking mode),
> and not block on pipe output (to avoid deadlock)

Yes. Sounds correct. Although the more I think about it, the more I 
suspect that the whole NONBLOCK thing should probably have been two bits, 
and simply been about "nonblocking input" vs "nonblocking output" (so that 
you could control both sides on a call-by-call basis).

But I think that your patch is fundamentally correct with the semantics 
as-is.

		Linus
