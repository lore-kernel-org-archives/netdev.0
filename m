From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kcm: fix /proc memory leak
Date: Wed, 22 Jun 2016 16:33:06 -0400 (EDT)
Message-ID: <20160622.163306.696779857682895662.davem@davemloft.net>
References: <20160620093628.2784-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, tom@herbertland.com,
	netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620093628.2784-1-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 20 Jun 2016 11:36:28 +0200

> Every open of /proc/net/kcm leaks 16 bytes of memory as is reported by
> kmemleak:
> unreferenced object 0xffff88059c0e3458 (size 192):
>   comm "cat", pid 1401, jiffies 4294935742 (age 310.720s)
>   hex dump (first 32 bytes):
>     28 45 71 96 05 88 ff ff 00 10 00 00 00 00 00 00  (Eq.............
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff8156a2de>] kmem_cache_alloc_trace+0x16e/0x230
>     [<ffffffff8162a479>] seq_open+0x79/0x1d0
>     [<ffffffffa0578510>] kcm_seq_open+0x0/0x30 [kcm]
>     [<ffffffff8162a479>] seq_open+0x79/0x1d0
>     [<ffffffff8162a8cf>] __seq_open_private+0x2f/0xa0
>     [<ffffffff81712548>] seq_open_net+0x38/0xa0
> ...
> 
> It is caused by a missing free in the ->release path. So fix it by
> providing seq_release_net as the ->release method.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Fixes: cd6e111bf5 (kcm: Add statistics and proc interfaces)

Applied and queued up for -stable, thanks.
