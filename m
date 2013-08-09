From: Kumar Gaurav <kumargauravgupta3@gmail.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 08:15:01 +0530
Message-ID: <520457AD.9060508@gmail.com>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>  <20130808210918.GE5502@mwanda>  <20130808.142054.1541424422807503741.davem@davemloft.net>  <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com> <1376015984.2087.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dan.carpenter@oracle.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:58442 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233Ab3HICpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 22:45:14 -0400
In-Reply-To: <1376015984.2087.31.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 August 2013 08:09 AM, Joe Perches wrote:
> On Fri, 2013-08-09 at 07:54 +0530, Kumar Gaurav wrote:
>> On Friday 09 August 2013 03:03 AM, Joe Perches wrote:
>>> On Thu, 2013-08-08 at 14:20 -0700, David Miller wrote:
>>>> So what's the problem again? :-)
>> I'm quite new to kernel development. I saw in one of the patches which
>> fixes IRQF_DISABLED issue by removing so i did.
> Hi Kumar.
>
> No worries, welcome.
>
>>> Wouldn't it be better to do a sed 's/IRQF_DISABLED/0/' instead?
>>> Maybe Kumar wants to/is doing that?
>> Yes i wanted to do the same and i retrieved list of all programs
>> containing IRQF_DISABLED but i didn't wanted to send all of them in one
>> patch. I would be sending them for one program in one patch.
> You should definitely not send a single patch.
>
> $ git grep -w --name-only IRQF_DISABLED | wc -l
> 245
>
> I think that's way too many modified files for a
> single patch.
>
> If you do it, please remember to change bits like
> "(IRQF_<foo> | IRQF_DISABLED)" so that instead of
> "(IRQF_<foo> | 0)", you use just "IRQF_<foo>".
>
> And, maybe it'd be better to use IRQF_TRIGGER_NONE
> instead of 0.
I tried googling what to replace IRQF_DISABLED with but found nothing. 
In the patch fixed earlier (not by me) it was replaced with 0 so i did 
same. But from now on I'll use IRQF_TRIGGER_NONE. Thanks
> Perhaps you could send patches bundled together
> in sensible chunks, say, second level directories.
>
> Something like:
>
> $ git grep -w --name-only IRQF_DISABLED | cut -f1,2 -d"/" | uniq -c
>        1 Documentation/PCI
>        3 Documentation/scsi
>       62 arch/arm
>        1 arch/avr32
>       14 arch/cris
>        4 arch/frv
>        4 arch/h8300
>        5 arch/ia64
>        1 arch/m32r
>        7 arch/m68k
>        1 arch/microblaze
>        4 arch/mn10300
>        1 arch/score
>        2 arch/sparc
>        6 arch/x86
>        5 drivers/block
>        2 drivers/bus
>        1 drivers/cdrom
>        7 drivers/char
>       12 drivers/clocksource
>        1 drivers/crypto
>        5 drivers/dma
>        3 drivers/edac
>        2 drivers/isdn
>       21 drivers/media
>        2 drivers/misc
>        3 drivers/mtd
>       28 drivers/net
>        1 drivers/pnp
>       24 drivers/scsi
>        1 drivers/staging
>        2 drivers/tty
>        3 drivers/usb
>        2 drivers/w1
>        2 drivers/xen
>        1 include/linux
>        1 include/net
>
>
>
Okay I'll be sending patch on the second level directory.

Regards
Kumar Gaurav
