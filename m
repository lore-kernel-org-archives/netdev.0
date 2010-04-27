From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 27 Apr 2010 15:32:39 -0700
Message-ID: <20100427153239.0977c1aa.randy.dunlap@oracle.com>
References: <20100427091405.GA5098@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:26974 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757358Ab0D0Wdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:33:44 -0400
In-Reply-To: <20100427091405.GA5098@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Apr 2010 11:14:05 +0200 Richard Cochran wrote:

Hi,

How do I use the testptp.mk file?

$ cd Documentation/ptp
$ make -f *.mk
gcc -Wall -I/usr/include   -c -o testptp.o testptp.c
testptp.c:33:29: error: linux/ptp_clock.h: No such file or directory



> diff --git a/Documentation/ptp/testptp.mk b/Documentation/ptp/testptp.mk
> new file mode 100644
> index 0000000..4ef2d97
> --- /dev/null
> +++ b/Documentation/ptp/testptp.mk
> @@ -0,0 +1,33 @@
> +# PTP 1588 clock support - User space test program
> +#
> +# Copyright (C) 2010 OMICRON electronics GmbH
> +#
> +#  This program is free software; you can redistribute it and/or modify
> +#  it under the terms of the GNU General Public License as published by
> +#  the Free Software Foundation; either version 2 of the License, or
> +#  (at your option) any later version.
> +#
> +#  This program is distributed in the hope that it will be useful,
> +#  but WITHOUT ANY WARRANTY; without even the implied warranty of
> +#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +#  GNU General Public License for more details.
> +#
> +#  You should have received a copy of the GNU General Public License
> +#  along with this program; if not, write to the Free Software
> +#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> +
> +CC        = $(CROSS_COMPILE)gcc
> +INC       = -I$(KBUILD_OUTPUT)/usr/include
> +CFLAGS    = -Wall $(INC)
> +LDLIBS    = -lrt
> +PROGS     = testptp
> +
> +all: $(PROGS)
> +
> +testptp: testptp.o
> +
> +clean:
> +	rm -f testptp.o
> +
> +distclean: clean
> +	rm -f $(PROGS)
> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> new file mode 100644
> index 0000000..458d0fe
> --- /dev/null
> +++ b/drivers/ptp/Kconfig
> @@ -0,0 +1,26 @@
> +#
> +# PTP clock support configuration
> +#
> +
> +menu "PTP clock support"
> +
> +config PTP_1588_CLOCK
> +	tristate "PTP clock support"
> +	depends on EXPERIMENTAL
> +	help
> +	  The IEEE 1588 standard defines a method to precisely
> +	  synchronize distributed clocks over Ethernet networks. The
> +	  standard defines a Precision Time Protocol (PTP), which can
> +	  be used to achieve synchronization within a few dozen
> +	  microseconds. In addition, with the help of special hardware
> +	  time stamping units, it can be possible to achieve
> +	  synchronization to within a few hundred nanoseconds.
> +
> +	  This driver adds support for PTP clocks as character
> +	  devices. If you want to use a PTP clock, then you should
> +	  also enable at least one clock driver as well.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called ptp_clock.ko.

Drop the ".ko".  We normally don't include that part of the module name.

> +
> +endmenu

> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index 2fc8e14..2d616cb 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -318,6 +318,7 @@ unifdef-y += poll.h
>  unifdef-y += ppp_defs.h
>  unifdef-y += ppp-comp.h
>  unifdef-y += pps.h
> +unifdef-y += ptp_clock.h
>  unifdef-y += ptrace.h
>  unifdef-y += quota.h
>  unifdef-y += random.h

I think that the Kbuild file also needs this line:
header-y += ptp_clock.h

so that builds that use O=objdir will work, but even with that
change, I couldn't get it to work.  (?)

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
