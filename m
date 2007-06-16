From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8635] New: EV6 version of csum_ipv6_magic
 causing unaligned access errors
Date: Sat, 16 Jun 2007 00:06:20 -0700
Message-ID: <20070616000620.72e56b86.akpm@linux-foundation.org>
References: <bug-8635-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: netdev@vger.kernel.org, Richard Henderson <rth@twiddle.net>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37787 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750708AbXFPHGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2007 03:06:46 -0400
In-Reply-To: <bug-8635-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Jun 2007 13:47:33 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8635
> 
>            Summary: EV6 version of csum_ipv6_magic causing unaligned access
>                     errors
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.18 & 2.6.22-rc4-mm2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: jailbird@alcatraz.fdf.net
> 
> 
> Most recent kernel where this bug did not occur: Unknown (Sorry!)
> Distribution: Debian/testing (lenny)
> Hardware Environment: API Networks CS20 (2 x 833Mhz 21264B Alpha CPUs)
> Software Environment:
> Linux sky 2.6.22-rc4-mm2 #1 SMP Tue Jun 12 23:00:10 CDT 2007 alpha GNU/Linux
> 
> Gnu C                  4.2.1
> Gnu make               3.81
> binutils               Binutils
> util-linux             2.12r
> mount                  2.12r
> module-init-tools      3.3-pre11
> e2fsprogs              1.40-WIP
> xfsprogs               2.8.18
> Linux C Library        > libc.2.5
> Dynamic linker (ldd)   2.5
> Procps                 3.2.7
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               5.97
> udev                   105
> Modules Loaded         nfnetlink ip_tables x_tables adm9240 hwmon_vid loop
> i2c_ali1535 i2c_ali15x3 i2c_core ide_cd cdrom generic sd_mod alim15x3 sym53c8xx
> ide_core e100 scsi_transport_spi mii scsi_mod
> 
> Problem Description:
> 
> jailbird@sky:~$ grep 'kernel unaligned' /proc/cpuinfo                 
> kernel unaligned acc    : 34 (pc=fffffc00004bbf58,va=fffffc000394811c)
> 
> fffffc00004bbdb0 T __copy_user
> fffffc00004bbf50 T csum_ipv6_magic
> fffffc00004bc020 T memchr
> 
> Seems to be associated w/ arch/alpha/lib/ev6-csum_ipv6_magic.S
> 
> Steps to reproduce:
> 
> Use IPv6 on an Alpha EV6 or higher CPU.
> 

I assume that networking passed the arch an unaligned pointer and the arch
didn't expect that.

I further assume that this is an alpha shortcoming, and that this behaviour
of networking is expected?

