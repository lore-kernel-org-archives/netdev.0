From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Thu, 8 Jan 2009 05:03:07 +0100
Message-ID: <5a4c581d0901072003j1d3c7d0dy9b2f4cdd68bc1663@mail.gmail.com>
References: <5a4c581d0901070624t6e769966t6b034b14d4732bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:9801 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbZAHEDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 23:03:10 -0500
In-Reply-To: <5a4c581d0901070624t6e769966t6b034b14d4732bd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2009 at 3:24 PM, Alessandro Suardi
<alessandro.suardi@gmail.com> wrote:
> From dmesg:
>
> [asuardi@sandman src]$ dmesg | grep tg3
> tg3.c:v3.97 (December 10, 2008)
> tg3 0000:02:00.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
> tg3 0000:02:00.0: setting latency timer to 64
> tg3 0000:02:00.0: wake-up capability disabled by ACPI
> tg3 0000:02:00.0: PME# disabled
> tg3 0000:02:00.0: firmware: requesting tigon/tg3_tso.bin
> tg3: Failed to load firmware "tigon/tg3_tso.bin"
> tg3 0000:02:00.0: PCI INT A disabled
> tg3: probe of 0000:02:00.0 failed with error -2
>
>
> But /lib/firmware/tigon/tg3_tso.bin is actually present:
>
> [asuardi@sandman src]$ ls -l /lib/firmware/tigon/tg3_tso.bin
> -rw-r--r-- 1 root root 7004 2009-01-06 22:58 /lib/firmware/tigon/tg3_tso.bin
>
>
>
> Diffing the .configs one can see CONFIG_KMOD disappeared; and
>  the output of the kernel build in -git8 also has the IHEX parts about
>  tg3 firmware which are new (I don't recall seeing those in the last
>  1000 builds or so ;)
>
> [asuardi@sandman src]$ diff .config-2.6.28-git[78]
> 3,4c3,4
> < # Linux kernel version: 2.6.28-git7
> < # Mon Jan  5 17:34:11 2009
> ---
>> # Linux kernel version: 2.6.28-git8
>> # Tue Jan  6 22:06:19 2009
> 133d132
> < CONFIG_KMOD=y
> 1324a1324
>> # CONFIG_TWL4030_CORE is not set
> 1591d1590
> < CONFIG_HID_BRIGHT=y
> 1595d1593
> < CONFIG_HID_DELL=y
> 1602a1601
>> CONFIG_HID_NTRIG=y
> 1608a1608,1609
>> # CONFIG_GREENASIA_FF is not set
>> CONFIG_HID_TOPSEED=y
> 1821c1822
> < # CONFIG_OCFS2_COMPAT_JBD is not set
> ---
>> CONFIG_OCFS2_FS_POSIX_ACL=y
> 1825c1826,1832
> < # CONFIG_QUOTA is not set
> ---
>> CONFIG_QUOTA=y
>> CONFIG_QUOTA_NETLINK_INTERFACE=y
>> # CONFIG_PRINT_QUOTA_WARNING is not set
>> CONFIG_QUOTA_TREE=y
>> # CONFIG_QFMT_V1 is not set
>> CONFIG_QFMT_V2=y
>> CONFIG_QUOTACTL=y
>
>
>
> [asuardi@sandman src]$ diff /tmp/make-kernel-2.6.28-git[78].out
> 669a670
>>   CC [M]  fs/ocfs2/blockcheck.o
> 692a694,695
>>   CC [M]  fs/ocfs2/quota_local.o
>>   CC [M]  fs/ocfs2/quota_global.o
> 693a697
>>   CC [M]  fs/ocfs2/acl.o
> 810a815,818
>>   CC      fs/dquot.o
>>   CC      fs/quota_v2.o
>>   CC      fs/quota_tree.o
>>   CC      fs/quota.o
> 1045c1053
> < /share/src/linux-2.6.28-git7/arch/x86/include/asm/string_32.h:75:
> warning: array subscript is above array bounds
> ---
>> /share/src/linux-2.6.28-git8/arch/x86/include/asm/string_32.h:75: warning: array subscript is above array bounds
> 1286d1293
> <   CC      drivers/hid/hid-bright.o
> 1290d1296
> <   CC      drivers/hid/hid-dell.o
> 1295a1302
>>   CC      drivers/hid/hid-ntrig.o
> 1300a1308
>>   CC      drivers/hid/hid-topseed.o
> 1521c1529
> < /share/src/linux-2.6.28-git7/arch/x86/include/asm/string_32.h:75:
> warning: array subscript is above array bounds
> ---
>> /share/src/linux-2.6.28-git8/arch/x86/include/asm/string_32.h:75: warning: array subscript is above array bounds
> 1983d1990
> < net/rfkill/rfkill.c:59: warning: 'rfkill_led_trigger' defined but not used
> 2234,2235c2241,2242
> < System is 2000 kB
> < CRC 8dd05de2
> ---
>> System is 2013 kB
>> CRC 37411210
> 2646a2654,2656
>>   IHEX    firmware/tigon/tg3.bin
>>   IHEX    firmware/tigon/tg3_tso.bin
>>   IHEX    firmware/tigon/tg3_tso5.bin
>
>
> So which is it, whatever the IHEX part did or the disappearance of
>  CONFIG_KMOD (which is in the -git8 patch, indeed) to cause
>  this issue ?
>
> Note that I don't have CONFIG_FIRMWARE_IN_KERNEL, but on
>  the other hand I didn't earlier, either... and yes, CONFIG_MODULES=y.
>
>
> thanks in advance, ciao,

Still broken in -git10, cc'ing netdev... h/w is the onboard
 Gigabit ethernet on my Dell Latitude D610, that is

02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5751
Gigabit Ethernet PCI Express (rev 01)

thanks,

--alessandro

 "Sun keeps rising in the west / I keep on waking fully confused"

   (The Replacements, "Within Your Reach")
