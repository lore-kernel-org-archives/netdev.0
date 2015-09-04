From: David Miller <davem@davemloft.net>
Subject: Re: BUG: sleeping function called from invalid context at
 mm/page_alloc.c:3186
Date: Fri, 04 Sep 2015 11:36:57 -0700 (PDT)
Message-ID: <20150904.113657.2146226970417029162.davem@davemloft.net>
References: <55E9A518.3080906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vinschen@redhat.com
To: pomidorabelisima@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933017AbbIDSg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 14:36:59 -0400
In-Reply-To: <55E9A518.3080906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: poma <pomidorabelisima@gmail.com>
Date: Fri, 4 Sep 2015 16:05:12 +0200

> Call Trace:
>  [<ffffffff81847119>] dump_stack+0x4b/0x63
>  [<ffffffff810d5329>] ___might_sleep+0x179/0x230
>  [<ffffffff810d5429>] __might_sleep+0x49/0x80
>  [<ffffffff811e541e>] __alloc_pages_nodemask+0x2fe/0xb90
>  [<ffffffff81429236>] ? debug_object_activate+0xb6/0x1e0
>  [<ffffffff814298c1>] ? debug_object_active_state+0x91/0x150
>  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
>  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
>  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
>  [<ffffffffa003725e>] rtl8169_map_counters+0x3e/0x70 [r8169]
>  [<ffffffffa0038674>] rtl8169_update_counters+0x64/0x140 [r8169]
>  [<ffffffffa00388ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
>  [<ffffffff816fc694>] dev_get_stats+0x54/0x100
>  [<ffffffff817254c7>] dev_seq_printf_stats+0x37/0x120
>  [<ffffffff817255c4>] dev_seq_show+0x14/0x30
>  [<ffffffff8128e41a>] seq_read+0x2fa/0x3e0
>  [<ffffffff812dbd92>] proc_reg_read+0x42/0x70
>  [<ffffffff81264c17>] __vfs_read+0x37/0x100
>  [<ffffffff81384ae3>] ? security_file_permission+0xa3/0xc0
>  [<ffffffff81265596>] vfs_read+0x86/0x130
>  [<ffffffff81266318>] SyS_read+0x58/0xd0
>  [<ffffffff81850db2>] entry_SYSCALL_64_fastpath+0x12/0x76
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=104031

Corinna, I think your changes introduced this bug.  Please take
a look.

Thanks.
