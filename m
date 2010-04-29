From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 14:02:59 +0200
Message-ID: <4BD97573.5050101@grandegger.com>
References: <20100427091344.GA5086@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43739 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758579Ab0D3SJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:09:25 -0400
In-Reply-To: <20100427091344.GA5086@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> Now and again there has been some talk on this list of adding PTP
> support into Linux. One part of the picture is already in place, the
> SO_TIMESTAMPING API for hardware time stamping. It has been pointed
> out that this API is not perfect, however, it is good enough for many
> real world uses of IEEE 1588. The second needed part has not, AFAICT,
> ever been addressed.
> 
> Here I offer an early draft of an idea how to bring the missing
> functionality into Linux. I don't yet have all of the features
> implemented, as described below. Still I would like to get your
> feedback concerning this idea before getting too far into it. I do
> have all of the hardware mentioned at hand, so I have a good idea that
> the proposed API covers the features of those clocks.
> 
> Thanks in advance for your comments,
> 
> Richard
> 
> * PTP infrastructure for Linux
> 
>   This patch set introduces support for IEEE 1588 PTP clocks in
>   Linux. Together with the SO_TIMESTAMPING socket options, this
>   presents standardized method for developing PTP user space programs,
>   synchronizing Linux with external clocks, and using the ancillary
>   features of PTP hardware clocks.
> 
>   A new class driver exports a kernel interface for specific clock
>   drivers and a user space interface. The infrastructure supports a
>   complete set of PTP functionality.
> 
>   + Basic clock operations
>     - Set time
>     - Get time
>     - Shift the clock by a given offset atomically
>     - Adjust clock frequency
> 
>   + Ancillary clock features
>     - One short or periodic alarms, with signal delivery to user program
>     - Time stamp external events
>     - Period output signals configurable from user space
>     - Synchronization of the Linux system time via the PPS subsystem
> 
> ** PTP kernel API
> 
>    A PTP clock driver registers itself with the class driver. The
>    class driver handles all of the dealings with user space. The
>    author of a clock driver need only implement the details of
>    programming the clock hardware. The clock driver notifies the class
>    driver of asynchronous events (alarms and external time stamps) via
>    a simple message passing interface.
> 
>    The class driver supports multiple PTP clock drivers. In normal use
>    cases, only one PTP clock is needed. However, for testing and
>    development, it can be useful to have more than one clock in a
>    single system, in order to allow performance comparisons.
> 
> ** PTP user space API
> 
>    The class driver creates a character device for each registered PTP
>    clock. User space programs may control the clock via standardized
>    ioctls. A program may query, enable, configure, and disable the
>    ancillary clock features. User space can receive time stamped
>    events via blocking read() and poll(). One shot and periodic
>    signals may be configured via an ioctl API with similar semantics
>    to the POSIX timer_settime() system call.
> 
> ** Supported hardware
> 
>    + Standard Linux system timer
>      - No special PTP features
>      - For use with software time stamping
> 
>    + Freescale eTSEC gianfar
>      - 2 Time stamp external triggers, programmable polarity (opt. interrupt)
>      - 2 Alarm registers (optional interrupt)
>      - 3 Periodic signals (optional interrupt)
> 
>    + National DP83640
>      - 6 GPIOs programmable as inputs or outputs
>      - 6 GPIOs with dedicated functions (LED/JTAG/clock) can also be
>        used as general inputs or outputs
>      - GPIO inputs can time stamp external triggers
>      - GPIO outputs can produce periodic signals
>      - 1 interrupt pin
> 
>    + Intel IXP465
>      - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
>      - Target Time (optional interrupt)

I realized two other netdev drivers already supporting PTP timestamping:
igb and bfin_mac. From the PTP developer point of view, the interface
looks rather complete to me and it works fine on my MPC8313 setup. The
only thing I stumbled over was that PTP clock registration failed when
PTP support is statically linked into the kernel.

Thanks,

Wolfgang.

