From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Sun, 24 Jul 2016 19:45:13 +0200
Message-ID: <1659922.nTqITfJpFk@debian64>
References: <201607240335.u6O3ZE81014171@sdf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, alexmcwhirter-O8/uFoRGvHWcqzYg7KEe8g@public.gmane.org
To: Alan Curry <rlwinm-WF+c3Tt1nJM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201607240335.u6O3ZE81014171-WF+c3Tt1nJM@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I added Al Viro to the CC (probably not necessary...)

On Sunday, July 24, 2016 3:35:14 AM CEST Alan Curry wrote:
> [1.] One line summary of the problem:
> network data corruption (bisected to e5a4b0bb803b)
> 
> [2.] Full description of the problem/report:
> Note: although my bisect ended at a commit from before 3.19, I have the
> same symptom in all newer kernels I've tried, up to 4.6.4.
> 
> The commit was:
> 
> >commit e5a4b0bb803b39a36478451eae53a880d2663d5b
> >Author: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> >Date:   Mon Nov 24 18:17:55 2014 -0500
> >
> >    switch memcpy_to_msg() and skb_copy{,_and_csum}_datagram_msg() to primitives
> 
> The symptom is that downloaded files (http, ftp, and probably other
> protocols) have small corrupted segments (about 1-2 kilobytes long) in
> random locations. Only downloads that sustain a high speed for at least a
> few seconds are corrupted. Anything small enough to be received in less
> than about 5 seconds is not affected.
> 
> If I download the same file twice in a row, the corruption is in different
> places in each copy.
> 
> If I try to do a git clone, it fails a few seconds into the "Receiving
> objects" stage with a deflate error.

Thanks for the detailed bug-report. I looked around the web to see if it
was already reported or not. If found that this issue was reported before:
[0], [1] and [2] by the same person (CC'ed). One difference is that the 
reporter had this issue with rsync on multiple SPARC systems. I ran a
git grep on a 4.7.0-rc7+ (wt-2016-07-21-15-g97bd3b0). But it didn't find
any patches directly referencing the commit. I'm not sure if this issue
has been fixed by now or not. I would greatly appreciate any comment
about this from the "people of netdev" (Al Viro? Alex Mcwhirter?).

As for carl9170: I'm not sure what the driver or firmware can do about
this at this time. You can try to disable the hardware crypto by setting
nohwcrypt via the module option. However, this might not do anything at all.

> [3.] Keywords: networking, carl9170
> 
> [4.] Kernel information
> [4.1.] Kernel version (from /proc/version):
> Multiple versions are known to be affected, from 3.19 to 4.6.4
> 
> [4.2.] Kernel .config file:
> For testing I built with make x86_64_defconfig followed by enabling the
> carl9170 driver, which adds these lines:
> CONFIG_ATH_COMMON=m
> CONFIG_ATH_CARDS=m
> CONFIG_CARL9170=m
> CONFIG_CARL9170_LEDS=y
> CONFIG_CARL9170_WPC=y
> 
> [5.] Most recent kernel version which did not have the bug:
> That would be the predecessor of e5a4b0bb803b39a36478451eae53a880d2663d5b
> which is v3.18-rc6-1620-g17836394e578
> 
> [6.] no Oops
> 
> [7.] A small shell script or example program which triggers the
>      problem (if possible)
> 
> This command fails reliably for me when running an affected kernel:
> 
> git clone git://git.kernel.org/pub/scm/git/git.git
> 
> (I'm including all the standard format stuff suggested by REPORTING-BUGS,
> but I think you can skip from here to section 8.7 without missing anything
> relevant)
Yes, I removed it for the most part. If anyone is interested in the details:
Here's a link to the original post @LKML [3].

> 
> [8.] Environment
> [8.1.] Software (add the output of the ver_linux script here)
> 
> Mostly Debian 8.5 stable packages here.
> 
> [8.3.] Module information (from /proc/modules):
> 
> When I tested with the x86_64_defconfig + carl9170 kernel, there were
> hardly any modules built, and I reproduced the problem after booting with
> init=/bin/sh, so no unnecessary modules were loaded. Currently running a
> normal 4.6.4 kernel which is showing the bug.
> 
> [...]
> [8.7.] Other information that might be relevant to the problem
>        (please look in /proc and include all information that you
>        think to be relevant):
> 
> lsusb identifies my network device as:
> 
> Bus 005 Device 004: ID 0cf3:1002 Atheros Communications, Inc. TP-Link TL-WN821N v2 802.11n [Atheros AR9170]
> 
> I have version 1.9.9 of carl9170-1.fw in /lib/firmware
Just one additional question: Is the TL-WN821N connected to a USB3 port?

Regards,
Christian

[0] <https://lists.debian.org/debian-sparc/2016/06/msg00160.html>
[1] <https://marc.info/?l=gentoo-sparc&m=145766845820114&w=2>
[2] <http://permalink.gmane.org/gmane.linux.ports.sparc/22507>
[3] <https://lkml.org/lkml/2016/7/23/184>



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
