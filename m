From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Wed, 30 Mar 2005 17:33:13 +0200
Message-ID: <20050330153313.GD32111@g5.random>
References: <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050330152208.GB12672@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 05:22:08PM +0200, Andi Kleen wrote:
> Which I think is pretty unlikely. Normally the dirty limits in the VM
> should prevent it anyways - VM is supposed to block before all
> your memory is dirty. The CPU can still dirty pages in user space,

This is not true for MAP_SHARED as I mentioned earlier in this thread.
The dirty limits can't trigger unless you want to take a page fault for
every single memory write opcode that touches a clean page (and as well
marking the pte clean and wrprotect during writepage).  And we're not
going to change anything for swap and anon/shm, so it would be still an
issue for swap over iscsi.

You can be right the receive path may be less of a pratical issue, but
it's still very much an at least theoretical source of deadlock.
