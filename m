From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: kernel 3.1.1 message:  <IRQ> warn_alloc_failed
Date: Fri, 9 Dec 2011 09:50:14 -0800
Message-ID: <20111209095014.14a647cd@nehalam.linuxnetplumber.net>
References: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: starlight@binnacle.cx, Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Dec 2011 21:10:02 -0500
starlight@binnacle.cx wrote:

> Hello.
> 
> FYI saw several of these when running
> multiple 'rcp' commands copying multi-gigabyte
> files to/from system.
> 
> 'rcp' target files were all on an encrypted
> mirrored USB3-attached pair of 3TB hard
> drives.
> 
> One outgoing 'rcp' was to a system with
> a much slower disk (due to a USB2 attachment)
> and that transfer was putting back-pressure
> on the connection.
> 
> Kernel is running on a CentOS 6.0
> distribution.
> 
> Not subscribing to the lists, so please
> CC me with any queries.  Please note that
> email originating from most non-US MTAs
> will bounce, but I will check the list
> archives if I see any.
> 
> Can't spend a lot of time on this but am
> willing to answer a few questions.  Hopefully
> the call stack will tell the story well
> enough.

You are seeing memory allocation failures because device
is allocating a 16K (order 2) size socket buffer. You are using
netxen device, and it looks like the problem.

>From reading the netxen driver source. The LRO buffers in this device
are very large (8060+skb overhead).
Until the driver is fixed to use fragmented page size memory,
I recommend turning off LRO.
