From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: kernel 3.1.1 message:  <IRQ> warn_alloc_failed
Date: Tue, 13 Dec 2011 11:42:13 -0600
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA8162593365@MNEXMB1.qlogic.org>
References: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
 <20111209095014.14a647cd@nehalam.linuxnetplumber.net>,<6.2.5.6.2.20111209130007.039b3078@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "starlight@binnacle.cx" <starlight@binnacle.cx>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111209130007.039b3078@binnacle.cx>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

Sorry for late reply.

Stephan,
Thanks for analyzing.

Yes, the netxen adapter does not support fragmented page memory.
They are not harmful messages. At that instant of time it may fail allocating
memory for some buffers in the ring but after enough memory is available
it will try to allocate memory for unallocated buffers in ring.

Or the other option could be to turn LRO off.

Rajesh  

________________________________________
From: starlight@binnacle.cx [starlight@binnacle.cx]
Sent: Friday, December 09, 2011 11:33 PM
To: Stephen Hemminger; Sony Chacko; Rajesh Borundia
Cc: linux-kernel; netdev
Subject: Re: kernel 3.1.1 message:  <IRQ> warn_alloc_failed

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
