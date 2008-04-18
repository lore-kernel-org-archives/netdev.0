From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer
	interface.
Date: Fri, 18 Apr 2008 11:59:59 -0700
Message-ID: <20080418115959.6b8fdfa7.akpm@linux-foundation.org>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181439.49051.rusty@rustcorp.com.au>
	<20080418041846.db15150b.akpm@linux-foundation.org>
	<200804190032.39626.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200804190032.39626.rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, 19 Apr 2008 00:32:39 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:

> > Isn't this kinda-sorta like what a relayfs file does?  The oprofile
> > buffers?  etc?  Nothing in common at all, no hope?
> 
> An excellent question, but I thought the modern kernel etiquette was to only 
> comment on whitespace and formatting, and call it "review"? :)
> 
> Yes, kinda-sorta in that it's a ring buffer.  No, in that it's bidir and 
> consumption can be out-of-order (kind of important for I/O buffers).
> 
> But the reason I'm not proposing it as a syscall is that I'm not convinced 
> it's the One True Solution which everyone should be using.  Time will tell: 
> it's clearly not tied to tun and it's been generically useful for virtual 
> I/O, but history has not been kind to new userspace interfaces.

This is may be our third high-bandwidth user/kernel interface to transport
bulk data ("hbukittbd") which was implemented because its predecessors
weren't quite right.  In a year or two's time someone else will need a
hbukittbd and will find that the existing three aren't quite right and will
give us another one.  One day we need to stop doing this ;)

It could be that this person will look at Rusty's hbukittbd and find that
it _could_ be tweaked to do what he wants, but it's already shipping and
it's part of the kernel API and hence can't be made to do what he wants.

So I think it would be good to plonk the proposed interface on the table
and have a poke at it.  Is it compat-safe?  Is it extensible in a
backward-compatible fashion?  Are there future-safe changes we should make
to it?  Can Michael Kerrisk understand, review and document it?  etc.

You know what I'm saying ;)  What is the proposed interface?
