From: "George G. Davis" <gdavis@mvista.com>
Subject: Re: Segmentation fault when using ping6
Date: Thu, 7 Oct 2010 09:04:28 -0400
Message-ID: <20101007130428.GA22471@mvista.com>
References: <4CADBC7A.6060908@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Rogerio Pimentel <rogerio.pimentel@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:48772 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760503Ab0JGNEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 09:04:32 -0400
Received: by qyk10 with SMTP id 10so773069qyk.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 06:04:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4CADBC7A.6060908@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 09:26:34AM -0300, Rogerio Pimentel wrote:
> Hi,
> 
> I'm having a "segmentation fault" problem when using ping6.
> 
> When testing on ARM9 platforms (i.MX25 and i.MX27), it returns the error:
> 
> root@freescale ~$ ping6 ::1
> PING ::1 (::1): 56 data bytes
> Segmentation fault
> 
> When testing on ARM11 and ARM Cortex A8 platforms (i.MX31 and
> i.MX51), it works:
> 
> root@freescale ~$ ping6 ::1
> PING ::1 (::1): 56 data bytes
> 64 bytes from ::1: seq=0 ttl=64 time=0.331 ms
> 64 bytes from ::1: seq=1 ttl=64 time=0.214 ms
> 64 bytes from ::1: seq=2 ttl=64 time=0.176 ms
> 64 bytes from ::1: seq=3 ttl=64 time=0.155 ms
> 
> On all cases, I'm using Linux Kernel 2.6.35 (from Mainline) and
> Busybox 1.15.0
> 
> Does anybody have any idea?

Random guess is that you may be using a userland tuned for ARMv6 or later
but trying to run that on <ARMv6 machines.

You can enable this to see what's going wrong:

config DEBUG_USER
        bool "Verbose user fault messages"
        help
          When a user program crashes due to an exception, the kernel can
          print a brief message explaining what the problem was. This is
          sometimes helpful for debugging but serves no purpose on a
          production system. Most people should say N here.

          In addition, you need to pass user_debug=N on the kernel command
          line to enable this feature.  N consists of the sum of:

              1 - undefined instruction events
              2 - system calls
              4 - invalid data aborts
              8 - SIGSEGV faults
             16 - SIGBUS faults

--
Regards,
George

> 
> Thanks in advance,
> 
> Rogerio Pimentel
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
