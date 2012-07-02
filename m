From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Mon, 2 Jul 2012 15:41:19 -0400
Message-ID: <CAAsGZS6ahzUo+QRcLOyPcj5=mp53O+M9kqByOwPb0zZcr-cgwQ@mail.gmail.com>
References: <1341237299.22621.88.camel@edumazet-glaptop>
	<1341245191.2177.40.camel@schurl.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Gruenbacher <agruen@linbit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341245191.2177.40.camel@schurl.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 2, 2012 at 12:06 PM, Andreas Gruenbacher <agruen@linbit.com> wrote:
> On Mon, 2012-07-02 at 15:54 +0200, Eric Dumazet wrote:
>> So I will just say no to your patches, unless you demonstrate the
>> splice() problems, and how you can fix the alignment problem in a new
>> layer instead of in the existing zero copy standard one.
>
> Again, splice or not is not the issue here. It does not, by itself, allow zero
> copy from the network directly to disk but it could likely be made to support
> that if we can get the alignment right first.  The proposed MSG_NEW_PACKET flag
> helps with that, but maybe someone has a better idea.
>

Eric - by using splice do you mean something like:

int filedes[2];
PIPE_SIZE (64*1024)
pipe(filedes);
ret = splice (sock_fd_from, &from_offset, filedes [1], NULL, PIPE_SIZE,
                     SPLICE_F_MORE | SPLICE_F_MOVE);


ret = splice (filedes [0], NULL, file_fd_to,
                         &to_offset, ret,
                         SPLICE_F_MORE | SPLICE_F_MOVE);


i.e. splice-in from socket to pipe, and splice-out from pipe to destination?

Andreas - if the above assumption is true then can you apply the
'MSG_NEW_PACKET' on the sender and see if the above pseudo-splice code
achieves something similar to what you expect on the receive side(you
can also play w/ F_SETPIPE_SZ -  although I found very little
reduction in CPU usage)? Note: My personal experience - using splice
from an input-file-A to output-file-B bought very minimal cpu
reduction(yes, both the files used O_DIRECT). Instead, a simple
read/write w/ O_DIRECT from file-A to file-B was much much faster.


Chetan
