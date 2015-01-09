From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: Fw: iproute2: segfault with ip link show dev
Date: Fri, 9 Jan 2015 18:59:34 +0200
Message-ID: <20150109165934.GA18229@angus-think.wlc.globallogic.com>
References: <20150107114217.42bf2392@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vadim4j@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:32797 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbAIRKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:10:01 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so15536623lam.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:09:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150107114217.42bf2392@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 11:42:17AM -0800, Stephen Hemminger wrote:
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

I have a working patch which was tested by William and will send it
soon.

Regards,
Vadim Kochan
