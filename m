From: Jan Olderdissen <jan@ixiacom.com>
Subject: RE: [PATCH 2.6.5] Re: Fw: Stack sends SYN/ACKs even though accept
	 queue is full
Date: Fri, 30 Apr 2004 23:14:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15FDCE057B48784C80836803AE3598D50627AC8B@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@oss.sgi.com, David Miller <davem@redhat.com>,
        Andrew Morton
	 <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Nivedita Singhvi'" <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:

> Attaching a patch which adds a sysctl to turn off this
> behaviour.   Could you test this, please?  Patch against
> 2.6.5 vanilla kernel.  If you need a 2.4 version, let me
> know.

We'll be happy to test it. We would prefer a 2.4 kernel patch though. Ideal
would be 2.4.21 vanilla which we use in our embedded systems, but we can
make other targets work as well.

> Normally, I think the expected behaviour was that connections
> would be short-lived. This is a reasonable expectation for most
> web-servers etc.   In which case, the accept queue would free
> up frequently, and having the syn request right there would save
> a full timeout and round trip over the Internet. i.e. useful in the
> common case.

I have to disagree. 

As the code is implemented right now, you get at most two pending young
connections in the syn queue in addition to the ones in the accept queue -
all others have already had their full timeout. I will argue that in high
load conditions it doesn't really matter whether you have one or two warm
connections sitting around or not because other new connections are going to
come by anyway sooner than you want to have them. If the server is able to
keep up, the accept queue is going to be mostly empty anyway.

The idea of having warm connections is a good one - that is what the accept
queue is for. As long as the accept queue is not full, the syn queue will
have warm bodies for you. If the user wanted to achieve a very similar
effect, he could simply increase the accept queue size by 2.

In the end I don't think the minimal benefit warrants complicating the code
and/or adding an option that few would understand or care to know about.
Also, the concept of suggesting to the client that there is a receiver and
then just dropping all the packets it sends seems a bit rude if not outright
non-compliant.

Your call, of course.

Jan
