From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BRIDGE] warning message when add an interface to bridge
Date: Wed, 5 Dec 2007 22:56:00 -0500
Message-ID: <20071205225600.1feacfca@shemminger-laptop>
References: <3f696b20712041844h7c049b71reda92edd7b8cb16e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: "Chung-Chi Lo" <linolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39938 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041AbXLFD42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 22:56:28 -0500
In-Reply-To: <3f696b20712041844h7c049b71reda92edd7b8cb16e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Dec 2007 10:44:17 +0800
"Chung-Chi Lo" <linolo@gmail.com> wrote:

> My kernel is Linxu 2.6.22.1. SYSFS is off.
> When adding an interface to bridge, console will show WARNING message.
> If turn SYSFS to on, then the WARNING message is gone.
> Any suggestion how to debug this problem? Thanks.
> 
> # ifconfig eth0 0.0.0.0
> eth0: starting interface.
> # brctl addbr br0
> # brctl addif br0 eth0
> WARNING: at lib/kref.c:33 kref_get()
> Call Trace:
> [<80027844>] dump_stack+0x8/0x38
> [<8011f348>] kref_get+0xdc/0xe4
> [<8011ee20>] kobject_get+0x20/0x34
> [<8011e910>] kobject_shadow_add+0x5c/0x170
> [<8011ea34>] kobject_add+0x10/0x20
> [<8020aac0>] br_add_if+0xb4/0x1b4
> [<8020b354>] add_del_if+0x5c/0x118
> [<8020bcc4>] br_dev_ioctl+0x6c/0x88
> [<80182edc>] dev_ifsioc+0x334/0x3c0
> [<80183184>] dev_ioctl+0x21c/0x2ec
> [<8016f76c>] sock_ioctl+0x130/0x2e4
> [<800b3b2c>] do_ioctl+0x6c/0x84
> [<800b3d40>] vfs_ioctl+0x80/0x248
> [<800b3f58>] sys_ioctl+0x50/0x98
> [<8002a8a8>] stack_done+0x20/0x3c
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This is an an artifact of the kobject_shadow code which was reverted in later kernels.
It is gone in 2.6.23
