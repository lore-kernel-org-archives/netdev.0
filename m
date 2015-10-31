From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 00:09:43 +0000
Message-ID: <20151031000943.GL22011@ZenIV.linux.org.uk>
References: <20151029001532.GE22011@ZenIV.linux.org.uk>
 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151029041611.GF22011@ZenIV.linux.org.uk>
 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
 <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
 <20151030223317.GK22011@ZenIV.linux.org.uk>
 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2015 at 04:52:41PM -0700, Linus Torvalds wrote:

> I really suspect this patch is "good enough" in reality, and I would
> *much* rather do something like this than add a new non-POSIX flag
> that people have to update their binaries for. I agree with Eric that
> *some* people will do so, but it's still the wrong thing to do. Let's
> just make performance with the normal semantics be good enough that we
> don't need to play odd special games.
> 
> Eric?

IIRC, at least a part of what Eric used to complain about was that on
seriously multithreaded processes doing a lot of e.g. socket(2) we end up
a lot of bouncing the cacheline containing the first free bits in the bitmap.
But looking at the whole thing, I really wonder if the tons of threads asking
for random bytes won't get at least as bad cacheline bouncing while
getting said bytes, so I'm not sure if that rationale has survived.

PS: this problem obviously exists in Linus' variant as well as in mine;
the question is whether Eric's approach manages to avoid it in the first place.
