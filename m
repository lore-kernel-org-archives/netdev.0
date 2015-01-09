From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: Fw: iproute2: segfault with ip link show dev
Date: Fri, 9 Jan 2015 13:43:36 +0200
Message-ID: <CAMw6YJK9CuAPRGAgnVk5n2G4a7rz8T4ey1+K5eYf-_ctcgeG7g@mail.gmail.com>
References: <20150107114217.42bf2392@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:42315 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068AbbAILnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 06:43:37 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so1707693wiw.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 03:43:36 -0800 (PST)
In-Reply-To: <20150107114217.42bf2392@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I really don't know about VF thing but I did a diff of 3.15.0 and
3.16.0 in ip/ipaddress.c
and seems in print_vfinfo:

    vf_rate = RTA_DATA(vf[IFLA_VF_RATE]);

might be a NULL ?

Regards,

On Wed, Jan 7, 2015 at 9:42 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Looks like one VF info changes broke old code
>
> Begin forwarded message:
>
> Date: Wed, 7 Jan 2015 04:06:53 -0800
> From: William Dauchy <william@gandi.net>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: iproute2: segfault with ip link show dev
>
>
> Hi,
>
> I was using iproute2 3.15.
> My network card in using igb driver with VF enable, e.g igb.max_vfs=2
> After upgrading to 3.16, I have now a segfault while doing a
> usual `ip link show dev eth1`.
> Disabling VFS make the segafult disappear.
>
> Here is the gdb trace even if it does not contain much info.
> The segfault occurs when at the VF step.
>
> (gdb) break print_linkinfo
> Breakpoint 1 at 0x40782d
> (gdb) set args link show dev eth1
> (gdb) r
> Starting program: /sbin/ip link show dev eth1
>
> Breakpoint 1, 0x000000000040782d in print_linkinfo ()
> (gdb) n
> Single stepping until exit from function print_linkinfo,
> which has no line number information.
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP
> mode DEFAULT group default qlen 10000
>     link/ether 00:26:6c:ff:b5:c1 brd ff:ff:ff:ff:ff:ff
>
> Program received signal SIGSEGV, Segmentation fault.
> 0x00000000004070eb in print_vfinfo ()
> (gdb) bt
> #0  0x00000000004070eb in print_vfinfo ()
> #1  0x0000000000407f9f in print_linkinfo ()
> #2  0x000000000041f266 in iplink_get ()
> #3  0x0000000000409c69 in ipaddr_list_flush_or_save ()
> #4  0x000000000040a113 in ipaddr_list_link ()
> #5  0x00000000004203f6 in do_iplink ()
> #6  0x0000000000405a07 in do_cmd ()
> #7  0x000000000040621e in main ()
>
> The expected output is for example:
>
> # ip link show dev eth1
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP mode DEFAULT group default qlen 10000
>     link/ether 00:26:6c:ff:b3:8d brd ff:ff:ff:ff:ff:ff
>     vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
>     vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
>
>
> I'm using my own kernel build, a stable v3.14.x
>
> Regards,
> --
> William
