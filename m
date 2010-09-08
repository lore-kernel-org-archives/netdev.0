From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: r8169 not workin on resume due allocation failure
Date: Tue, 7 Sep 2010 21:11:28 -0700
Message-ID: <E4FE5659-F160-424C-92E7-4F7D3972E50C@earthlink.net>
References: <loom.20100908T054044-695@post.gmane.org>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Holger Freyther <zecke@selfish.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:59004 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750901Ab0IHERS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 00:17:18 -0400
In-Reply-To: <loom.20100908T054044-695@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger, et al,

Actually wouldn't it make sense if a system type fix is done?

I would add a delay if not already done and check to see
 if some dirty pages could be cleaned, then freed.

The assumption is then those pages would be minor faulted
back in and prefetched.

Another approach is to make sure that pages are cleaned on
a more frequent basis independent on the number of free
pages (free pages may not be continuous) that wants to make 
sure higher order allocs are allocatable over time.

Mitchell Erblich

On Sep 7, 2010, at 8:44 PM, Holger Freyther wrote:

> Hi all,
> 
> I'm using the r8169 module on my notebook and after a couple of days
> of running with suspend/resume the networking stops working. I have
> the dmesg output at the end of the email. From my understanding this
> is due that on suspend the interface will be brought down, the rx buffers
> are freed and that on resume it is not possible to allocate a continous
> buffer for the sizes required.
> 
> My approach to handle this would be to add an option to not free the
> buffers until the module is unloaded and guard this with an option. Is
> that an acceptable solution?
> 
> 
> NetworkManager: page allocation failure. order:3, mode:0x4020
> Pid: 1291, comm: NetworkManager \n
> Not tainted 2.6.35.4-12.fc14.i686.PAE #1
> Call Trace:
> [<c07e2197>] ? printk+0x25/0x2e
> [<c04c1af6>] __alloc_pages_nodemask+0x5bc/0x62f
> [<c04c1b83>] __get_free_pages+0x1a/0x2c
> [<c04e7bd6>] __kmalloc_track_caller+0x32/0x144
> [<c07465fb>] ? __netdev_alloc_skb+0x1b/0x36
> [<c07464fd>] __alloc_skb+0x59/0x100
> [<c07465fb>] __netdev_alloc_skb+0x1b/0x36
> [<f9796a8f>] rtl8169_rx_fill+0x99/0x132 [r8169]
> [<f9797913>] rtl8169_init_ring+0x66/0x96 [r8169]
> [<f9797e98>] rtl8169_open+0x7f/0x1d7 [r8169]
> [<c0750b04>] __dev_open+0x79/0xaa
> [<c0750cf9>] __dev_change_flags+0x98/0x10d
> [<c0750dde>] dev_change_flags+0x18/0x44
> [<c075976f>] do_setlink+0x253/0x52e
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

