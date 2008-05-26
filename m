From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Mon, 26 May 2008 14:33:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805261426010.16829@wrl-59.cs.helsinki.fi>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
 <20080521105747.215be17d.akpm@linux-foundation.org>
 <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
 <Pine.LNX.4.64.0805212310050.7747@wrl-59.cs.helsinki.fi>
 <cf4145200805211345y3b00d209o58e11a7b553cdfc6@mail.gmail.com>
 <Pine.LNX.4.64.0805231302410.16829@wrl-59.cs.helsinki.fi>
 <cf4145200805230906k34a0452at773e840b791e6b0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Brian Vowell <brian.vowell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43464 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204AbYEZLdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 07:33:10 -0400
In-Reply-To: <cf4145200805230906k34a0452at773e840b791e6b0a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 May 2008, Brian Vowell wrote:

> Here are some of the others that show in the logs:
> 
> This one repeats four times, and then again multiple times every minute
> afterwards for about 30 minutes.
> May 18 19:31:00 ishtar kernel: pdflush: page allocation failure. order:3,
> mode:0x4020

I think that the problem here is that tg3 tries to allocate a large 
contiguous memory block which isn't available.

> May 18 19:31:00 ishtar kernel: Pid: 15300, comm: pdflush Not tainted
> 2.6.25.4 #1
> May 18 19:31:00 ishtar kernel:
> May 18 19:31:00 ishtar kernel: Call Trace:
> May 18 19:31:00 ishtar kernel:  <IRQ>  [<ffffffff81075d35>]
> __alloc_pages+0x33f/0x35a
> May 18 19:31:00 ishtar kernel:  [<ffffffff810934a4>] new_slab+0x3f/0x242
> May 18 19:31:00 ishtar kernel:  [<ffffffff81093bba>]
> __slab_alloc+0x212/0x43b
> May 18 19:31:00 ishtar kernel:  [<ffffffff8128654c>]
> __netdev_alloc_skb+0x29/0x43
> May 18 19:31:00 ishtar kernel:  [<ffffffff8128654c>]
> __netdev_alloc_skb+0x29/0x43
> May 18 19:31:00 ishtar kernel:  [<ffffffff81094bd6>]
> __kmalloc_node_track_caller+0x75/0xab
> May 18 19:31:00 ishtar kernel:  [<ffffffff8128584a>] __alloc_skb+0x6a/0x133
> May 18 19:31:00 ishtar kernel:  [<ffffffff8128654c>]
> __netdev_alloc_skb+0x29/0x43
> May 18 19:31:00 ishtar kernel:  [<ffffffff8123a405>]
> tg3_alloc_rx_skb+0xc4/0x153
> May 18 19:31:00 ishtar kernel:  [<ffffffff81241343>] tg3_poll+0x3be/0x7df


...but I'm probably not much of help with it.


-- 
 i.
