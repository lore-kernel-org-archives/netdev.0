From: Nicholas Miell <nmiell@comcast.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 18:51:06 -0700
Message-ID: <1156297866.2476.208.camel@entropy>
References: <1156276823.2476.22.camel@entropy>
	 <20060822.133606.48392664.davem@davemloft.net>
	 <1156281220.2476.65.camel@entropy>
	 <20060822.142500.11271092.davem@davemloft.net>
	 <1156287511.2476.137.camel@entropy>  <44EB974B.3030200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932267AbWHWBvj@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
In-Reply-To: <44EB974B.3030200@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 16:46 -0700, Ulrich Drepper wrote:
> I so far also haven't taken the time to look exactly at the interface.
> I plan to do it asap since this is IMO our big chance to get it right.
> I want to have a unifying interface which can handle all the different
> events we need and which come up today and tomorrow.  We have to be able
> to handle not only file descriptors and AIO but also timers, signals,
> message queues (OK, they are file descriptors but let's make it
> official), futexes.  I'm probably missing the one or the other thing now.

Are you sure about signals? I thought about that, but they generally
fall into two categories: signals that have to be signals (i.e. SIGILL,
SIGABRT, SIGFPE, SIGSEGV, etc.) and signals that should be replaced a
queued event notification (SIGALRM, SIGRTMIN-SIGRTMAX).

Of course, that leaves things like SIGTERM, SIGINT, SIGQUIT, etc. so,
uh, nevermind then. Signal redirection to event queues is definitely
needed.

> DaveM says there are example programs for the current interfaces.  I
> must admit I haven't seen those either.  So if possible, point the world
> to them again.  If you do that now I'll review everything and write up
> my recommendations re the interface before Monday.

There's a handful of little test apps at
http://tservice.net.ru/~s0mbre/archive/kevent/ , but they don't work
with the current iteration of the interface. I don't know if there are
others somewhere else.

-- 
Nicholas Miell <nmiell@comcast.net>
