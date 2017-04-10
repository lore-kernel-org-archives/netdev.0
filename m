From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: WARN_ON running XDP on virtio net device
Date: Tue, 11 Apr 2017 00:37:54 +0300
Message-ID: <20170411003729-mutt-send-email-mst@kernel.org>
References: <9370d199-9a73-308c-97d0-8d473e8536b2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752040AbdDJVhz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 17:37:55 -0400
Content-Disposition: inline
In-Reply-To: <9370d199-9a73-308c-97d0-8d473e8536b2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 03:21:53PM -0600, David Ahern wrote:
> I'm hitting a WARN_ON running XDP with virtio net:

I just sent a pull request. Would appreciate reports on whether
it helps.

> [  177.185570] ------------[ cut here ]------------
> [  177.187250] WARNING: CPU: 0 PID: 880 at
> /home/dsa/kernel.git/drivers/pci/msi.c:1251 pci_irq_vector+0x92/0x123
> [  177.190932] Modules linked in: 8021q garp mrp stp llc vrf
> [  177.193473] CPU: 0 PID: 880 Comm: xdp1 Not tainted 4.11.0-rc5+ #305
> [  177.195640] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [  177.199190] Call Trace:
> [  177.200072]  dump_stack+0x81/0xb6
> [  177.201018]  __warn+0x107/0x122
> [  177.201899]  warn_slowpath_null+0x1d/0x1f
> [  177.203014]  pci_irq_vector+0x92/0x123
> [  177.204082]  vp_synchronize_vectors+0x6f/0x81
> [  177.205293]  vp_reset+0x50/0x55
> [  177.206174]  virtnet_xdp+0x346/0x6dd
> [  177.207188]  dev_change_xdp_fd+0x12a/0x151
> [  177.208256]  do_setlink+0x1288/0x130a
> 
> Seems to be something introduced in the past month or so. 2 attempts to
> bisect it pointed to this commit:
> 
> commit 54d7989f476ca57fc3c5cc71524c480ccb74c481
> Merge: 0f221a3102bb c4baad50297d
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Thu Mar 2 13:53:13 2017 -0800
> 
>     Merge tag 'for_linus' of
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost
> 
>     Pull vhost updates from Michael Tsirkin:
>      "virtio, vhost: optimizations, fixes
