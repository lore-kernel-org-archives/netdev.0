From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: ATL1E 0000:02:00.0: swiotlb buffer is full (sz: 529461 bytes)
Date: Fri, 18 Sep 2015 08:21:33 +0200
Message-ID: <20150918062133.GA411@x4>
References: <20150912065155.GA421@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:52491 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbbIRGVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 02:21:38 -0400
Content-Disposition: inline
In-Reply-To: <20150912065155.GA421@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015.09.12 at 08:51 +0200, Markus Trippelsdorf wrote:
> With the current Linus git tree I get an occasional swiotlb allocation
> error during network setup at boot-time:
> 
>  ATL1E 0000:02:00.0: swiotlb buffer is full (sz: 529461 bytes)
>  swiotlb: coherent allocation failed for device 0000:02:00.0 size=529461
>  CPU: 0 PID: 200 Comm: ifconfig Not tainted 4.2.0-11400-gdfb22fc5c0eb-dirty #113
>  Hardware name: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
>   00000000ffffffff ffffffff812b8d33 ffffffffffffffff ffffffff812da574
>   ffffffff00000008 ffff880216827000 ffff880216827740 ffff880216af0000
>   0000000000081435 ffffffff81c163c0 ffff880216b1b800 ffffffff814e3b1d
>  Call Trace:
>   [<ffffffff812b8d33>] ? dump_stack+0x40/0x6d
>   [<ffffffff812da574>] ? swiotlb_alloc_coherent+0x134/0x160
>   [<ffffffff814e3b1d>] ? atl1e_open+0xfd/0x460
>   [<ffffffff815ddfa2>] ? __dev_open+0x82/0x100
>   [<ffffffff815de271>] ? __dev_change_flags+0x91/0x160
>   [<ffffffff815de35e>] ? dev_change_flags+0x1e/0x60
>   [<ffffffff815d9b14>] ? dev_get_by_name_rcu+0x54/0x80
>   [<ffffffff8164c256>] ? devinet_ioctl+0x5d6/0x6a0
>   [<ffffffff815c418d>] ? sock_ioctl+0xed/0x1e0
>   [<ffffffff811258b1>] ? do_vfs_ioctl+0x291/0x480
>   [<ffffffff81063940>] ? __do_page_fault+0x140/0x380
>   [<ffffffff81125ad6>] ? SyS_ioctl+0x36/0x80
>   [<ffffffff8106a297>] ? entry_SYSCALL_64_fastpath+0x12/0x66
>  ATL1E 0000:02:00.0 eth0: pci_alloc_consistent failed, size = D529461
> 
> This happens every forth or fifth boot, so the issue is not bisectable.

Adding CC.

-- 
Markus
