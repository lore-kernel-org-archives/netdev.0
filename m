From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Wed, 30 Mar 2005 09:24:13 -0800
Message-ID: <20050330172412.GP15453@waste.org>
References: <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, andrea@suse.de, michaelc@cs.wisc.edu,
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
> On Tue, Mar 29, 2005 at 04:08:32PM -0500, jamal wrote:
> > Sender is holding onto memory (retransmit queue i assume) waiting
> > for ACKs. Said sender is under OOM and therefore drops ACKs coming in
> > and as a result cant let go of these precious resource sitting on the
> > retransmit queue. 
> > And iscsi cant wait long enough for someone else to release memory so
> > the ACKs can be delivered. 
> > Did i capture this correctly?
> 
> Or worse your swap device is on iscsi and you need the ACK to free
> memory. 
> 
> But that is unrealistic because it could only happen if 100% of
> your memory is dirty  pages or filled up by other non VM users.
> Which I think is pretty unlikely. Normally the dirty limits in the VM
> should prevent it anyways - VM is supposed to block before all
> your memory is dirty. The CPU can still dirty pages in user space,
> but the cleaner should also clean it and if necessary block
> the process.

I seem to recall this being fairly easy to trigger by simply pulling
the network cable while there's heavy mmap + write load. The system
will quickly spiral down into OOM and will remain wedged when you plug
the network back in. With iSCSI, after some extended period all the
I/Os will have SCSI timeouts and lose everything.

It's going to be fairly typical for iSCSI boxes to do all their I/O
over iSCSI, including swap and root. Things like blades and cluster
nodes.

-- 
Mathematics is the supreme nostalgia of our time.
