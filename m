From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sun, 27 Mar 2005 11:58:46 -0800
Message-ID: <20050327195846.GD15453@waste.org>
References: <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <1111907130.4753.32.camel@mylaptop> <20050326235712.25f9ca36.davem@davemloft.net> <1111911493.5824.12.camel@mylaptop> <4246FAD5.5080700@cs.wisc.edu> <20050327103115.5c746472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>, open-iscsi@googlegroups.com,
        andrea@suse.de, James.Bottomley@HansenPartnership.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050327103115.5c746472.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 27, 2005 at 10:31:15AM -0800, David S. Miller wrote:
> On Sun, 27 Mar 2005 10:26:29 -0800
> Mike Christie <michaelc@cs.wisc.edu> wrote:
> 
> > reliable receive is ciritical for WRITEs. Even if the WRITE is executed
> > successfully on the remote device, if we cannot receive the return status
> > from the device the operation will fail at the iscsi driver side due to a
> > SCSI timeout.
> 
> I keep hearing this word "reliable", it means something very
> different for TCP over a transport like IP than it does
> for the SCSI layer.

This has nothing to do with the specifics of TCP or IP.

We are out of memory. To free memory, we must be able to send N
packets and receive M acknowledgements. Sending and receiving packets
requires allocations - if we cannot allocate, we are permanently
wedged.

This strongly suggests we need to have private reserves that the
network layer knows how to access to fullfill higher level write
requests. A closely analogous situation exists with regular SCSI,
where the transport is also potentially lossy.

(In the iSCSI case, it's somewhat worse: we may need to open a new
socket or have one in reserve.)

-- 
Mathematics is the supreme nostalgia of our time.
