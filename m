From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: gigabit ethernet
Date: Fri, 13 Feb 2004 17:11:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213221108.GA16586@gtf.org>
References: <Pine.LNX.4.44.0402131116590.24993-100000@fast2.cs.caltech.edu> <402D424A.5060901@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cheng Jin <chengjin@cs.caltech.edu>,
        satya srikanth <satyasrikanth2001@yahoo.com>,
        "Xiaoliang (David) Wei" <weixl@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <402D424A.5060901@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2004 at 01:31:54PM -0800, Nivedita Singhvi wrote:
> Cheng Jin wrote:
> >
> >I read somewhere that Intel SMP has cpu0 taking care of 
> >all the hardware interrupts, but I don't know about softirqs.
> >I think all softirqs related to the GbE are handled by the
> >same cpu.
> 
> For incoming network packets, the hw interrupt handler simply
> schedules a local softirq to handle the rest of the input
> processing. So the softirq will execute on the same
> CPU that the hw interrupt came in on.

Many answers ;-)

1) Starting with Pentium4, all interrupts are delivered to cpu0...
unless software directs otherwise.  Thus it is helpful to have a
software irq balancing solution.  Red Hat has a userspace irqbalanced,
and kernel 2.6.x also has kirqd on x86.

2) For networking, receiving all packets on one cpu has many benefits,
and avoids packet reordering problems that occasionally appear on SMP.

3) For NAPI drivers, regardless of interrupt balancing strategy, packets
are usually receiving on one cpu.
