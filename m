From: starlight@binnacle.cx
Subject: Re: kernel 3.1.1 message:  <IRQ> warn_alloc_failed
Date: Fri, 09 Dec 2011 13:03:54 -0500
Message-ID: <6.2.5.6.2.20111209130007.039b3078@binnacle.cx>
References: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
 <20111209095014.14a647cd@nehalam.linuxnetplumber.net> <20111209095014.14a647cd@nehalam.linuxnetplumber.net
 >
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111209095014.14a647cd@nehalam.linuxnetplumber.net
 >
References: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
 <20111209095014.14a647cd@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 09:50 AM 12/9/2011 -0800, Stephen Hemminger wrote:
>On Thu, 08 Dec 2011 21:10:02 -0500 starlight@binnacle.cx wrote:
>
>You are seeing memory allocation failures because device
>is allocating a 16K (order 2) size socket buffer. You are using
>netxen device, and it looks like the problem.
>
>From reading the netxen driver source. The LRO buffers
>in this device are very large (8060+skb overhead).
>Until the driver is fixed to use fragmented page size memory,
>I recommend turning off LRO.

Thank you for the analysis.  As an alternative
would it make sense to double or quadruple

    /proc/sys/vm/min_free_kbytes

or perhaps do the same for

    /proc/slabinfo(size-16384)

or both?
