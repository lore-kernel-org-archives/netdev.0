From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Thu, 11 Dec 2008 10:24:21 +0000
Message-ID: <20081211102421.GB4129@ff.dom.local>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kernel@gentoo.org
To: Mathieu SEGAUD <mathieu.segaud@regala.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:40339 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630AbYLKKY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 05:24:27 -0500
Received: by ewy10 with SMTP id 10so1289596ewy.13
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 02:24:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87fxkwhyyq.fsf@barad-dur.regala.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-12-2008 15:44, Mathieu SEGAUD wrote:
> Hi,
> 
> we are experiencing some "virtual" network interfaces problem, especially
> with tun/tap devices and with bridges, which occasionally get stuck and
> won't deregister and hang the destroying process for very long time.
...
>  [<c0266b41>] netdev_run_todo+0xf7/0x19d
>  [<f8a7f3c5>] br_del_bridge+0x48/0x4c [bridge]
>  [<f8a7ff61>] br_ioctl_deviceless_stub+0x190/0x19f [bridge]
>  [<c018a66c>] inotify_d_instantiate+0x12/0x3a
>  [<c02e5c1b>] _spin_unlock+0xc/0x1f
>  [<f8a7fdd1>] br_ioctl_deviceless_stub+0x0/0x19f [bridge]
>  [<c025bf6e>] sock_ioctl+0x11f/0x1d9
>  [<c025be4f>] sock_ioctl+0x0/0x1d9
>  [<c0170cdc>] vfs_ioctl+0x1c/0x5f
>  [<c0170f47>] do_vfs_ioctl+0x228/0x23b
>  [<c025d76f>] sys_socketcall+0x51/0x19d
>  [<c0170f86>] sys_ioctl+0x2c/0x42
>  [<c01038a9>] sysenter_do_call+0x12/0x25
>  [<c02e0000>] print_cpu_info+0x7e/0x92
> 
> (This one was obtained with kernel version 2.6.27.4)
> 

Could you try e.g. 2.6.27.7 or something with this patch?:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.27.y.git;a=commit;h=58ec3b4db9eb5a28e3aec5f407a54e28f7039c19

Jarek P.
