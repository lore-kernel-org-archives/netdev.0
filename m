From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 0/3] [RFC] [v2] ptp: IEEE 1588 clock support
Date: Sat, 1 May 2010 11:32:47 -0500
Message-ID: <727B3C5E-39AA-4038-AB3F-EAC862654860@kernel.crashing.org>
References: <20100429091903.GA6691@riccoc20.at.omicron.at>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50073 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756277Ab0EAQcy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 12:32:54 -0400
In-Reply-To: <20100429091903.GA6691@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 29, 2010, at 4:19 AM, Richard Cochran wrote:

> * Patch ChangeLog
> ** v2
>   - Changed clock list from a static array into a dynamic list. Also,
>     use a bitmap to manage the clock's minor numbers.
>   - Replaced character device semaphore with a mutex.
>   - Drop .ko from module names in Kbuild help.
>   - Replace deprecated unifdef-y with header-y for user space header file.
>   - Gianfar driver now gets parameters from device tree.
>   - Added API documentation to Documentation/ptp/ptp.txt, with links
>     to both of the ptpd patches on sourceforge.
> 
> * Preface
> 
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
> 
> Richard Cochran (3):
>  ptp: Added a brand new class driver for ptp clocks.
>  ptp: Added a clock that uses the Linux system time.
>  ptp: Added a clock that uses the eTSEC found on the MPC85xx.
> 
> Documentation/ptp/ptp.txt             |   78 +++++++++
> Documentation/ptp/testptp.c           |  130 ++++++++++++++
> Documentation/ptp/testptp.mk          |   33 ++++
> arch/powerpc/boot/dts/mpc8313erdb.dts |   14 ++
> arch/powerpc/boot/dts/p2020ds.dts     |   13 ++
> arch/powerpc/boot/dts/p2020rdb.dts    |   14 ++
> drivers/Kconfig                       |    2 +
> drivers/Makefile                      |    1 +
> drivers/net/Makefile                  |    1 +
> drivers/net/gianfar_ptp.c             |  308 +++++++++++++++++++++++++++++++++
> drivers/net/gianfar_ptp_reg.h         |  107 ++++++++++++
> drivers/ptp/Kconfig                   |   51 ++++++
> drivers/ptp/Makefile                  |    6 +
> drivers/ptp/ptp_clock.c               |  302 ++++++++++++++++++++++++++++++++
> drivers/ptp/ptp_linux.c               |  122 +++++++++++++
> include/linux/Kbuild                  |    1 +
> include/linux/ptp_clock.h             |   37 ++++
> include/linux/ptp_clock_kernel.h      |  134 ++++++++++++++
> kernel/time/ntp.c                     |    2 +
> 19 files changed, 1356 insertions(+), 0 deletions(-)
> create mode 100644 Documentation/ptp/ptp.txt
> create mode 100644 Documentation/ptp/testptp.c
> create mode 100644 Documentation/ptp/testptp.mk
> create mode 100644 drivers/net/gianfar_ptp.c
> create mode 100644 drivers/net/gianfar_ptp_reg.h
> create mode 100644 drivers/ptp/Kconfig
> create mode 100644 drivers/ptp/Makefile
> create mode 100644 drivers/ptp/ptp_clock.c
> create mode 100644 drivers/ptp/ptp_linux.c
> create mode 100644 include/linux/ptp_clock.h
> create mode 100644 include/linux/ptp_clock_kernel.h

In the future please CC linuxppc-dev@lists.ozlabs.org and devicetree-discuss@lists.ozlabs.org since you are adding device tree bindings.

- k