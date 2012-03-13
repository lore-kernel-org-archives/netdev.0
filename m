From: Dave Jones <davej@redhat.com>
Subject: Re: tun oops dereferencing garbage nsproxy-> address.
Date: Tue, 13 Mar 2012 14:26:46 -0400
Message-ID: <20120313182646.GB11500@redhat.com>
References: <20120313034201.GA13156@redhat.com>
 <m1vcm8e537.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1vcm8e537.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 13, 2012 at 11:19:40AM -0700, Eric W. Biederman wrote:

 > > oops happened here..
 > >
 > >         tfile->net = get_net(current->nsproxy->net_ns);
 > >      548:       48 8b 92 50 05 00 00    mov    0x550(%rdx),%rdx
 > >      54f:       48 8b 52 28             mov    0x28(%rdx),%rdx
 > >
 > > My guess is the fuzzer called some syscall that set current->nsproxy
 > > to garbage (0x0000000100000001), which later got dereferenced when it
 > > subsequently randomly did an open() on tun.
 > >
 > > Any thoughts ?
 > 
 > It smells like a memory stomp.  current->nsproxy is always supposed to
 > have a valid value, and it never would have an odd value.  The value
 > should always be at least 8 byte aligned.
 > 
 > Since the value is impossible this doesn't feel like a path where the
 > error handling is wrong.

0x0000000100000001 looks like one of strange values my fuzzer passes syscalls
when they ask for an address.

So something managed to get that set as nsproxy.  The fuzzer avoids calling
clone(), so are there other syscalls that might set this ?

 > So I am guessing this is a memory stomp.  My guess it would take the
 > same sequence of system calls on the same kernel build to reproduce
 > this problem in the same place.
 > 
 > Do you have any more information?

I've not managed to reproduce it, and that run sadly had logging turned off,
so I don't have the exact syscall sequence that caused it.

	Dave
