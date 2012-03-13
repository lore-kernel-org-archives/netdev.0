From: Dave Jones <davej@redhat.com>
Subject: Re: tun oops dereferencing garbage nsproxy-> address.
Date: Tue, 13 Mar 2012 16:23:38 -0400
Message-ID: <20120313202338.GA23737@redhat.com>
References: <20120313034201.GA13156@redhat.com>
 <m1vcm8e537.fsf@fess.ebiederm.org>
 <20120313182646.GB11500@redhat.com>
 <m1wr6oclep.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1wr6oclep.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 13, 2012 at 01:10:06PM -0700, Eric W. Biederman wrote:

 > >  > > My guess is the fuzzer called some syscall that set current->nsproxy
 > >  > > to garbage (0x0000000100000001), which later got dereferenced when it
 > >  > > subsequently randomly did an open() on tun.
 > >  > 
 > >  > It smells like a memory stomp.  current->nsproxy is always supposed to
 > >  > have a valid value, and it never would have an odd value.  The value
 > >  > should always be at least 8 byte aligned.
 > >  > 
 > >  > Since the value is impossible this doesn't feel like a path where the
 > >  > error handling is wrong.
 > >
 > > 0x0000000100000001 looks like one of strange values my fuzzer passes syscalls
 > > when they ask for an address.
 > >
 > > So something managed to get that set as nsproxy.  The fuzzer avoids calling
 > > clone(), so are there other syscalls that might set this ?
 > 
 > setns and unshare might touch the nsproxy for the same reasons as clone,
 > but the rules are very similar to clone.

Hmm, the only way that seems possible to set nsproxy is if the process was run
with CAP_SYS_ADMIN, which it wasn't.

Maybe your theory holds water, and something else wrote that value to the
current thread at a random offset. Fun.

	Dave 
