From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: fix iomap leak
Date: Tue, 13 Jul 2010 22:14:28 +0900 (JST)
Message-ID: <20100713.221428.74744945.anemo@mba.ocn.ne.jp>
References: <1278756199-4636-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, davem@davemloft.net,
	jpirko@redhat.com, eric.dumazet@gmail.com, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from defer-dn03.ocn.ad.jp ([125.170.100.156]:54562 "EHLO
	defer-dn03.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928Ab0GMNvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 09:51:09 -0400
In-Reply-To: <1278756199-4636-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 Jul 2010 14:03:18 +0400, Kulikov Vasiliy <segooon@gmail.com> wrote:
> If tc35815_init_one() fails we must unmap mapped regions.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> ---
>  drivers/net/tc35815.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)

No, pcim_xxx APIs are _managed_ interfaces.  These resources are
released automatically.  Actually currently nobody in kernel call
pcim_iounmap_regions() now.

And _if_ there is any reason to call pcim_iounmap_regions()
explicitly, it should be called in tc35815_remove_one() too.

So, NAK.

---
Atsushi Nemoto
