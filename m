From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Sun, 12 Oct 2014 11:46:53 -0700
Message-ID: <1413139613.9362.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <543AB655.6060603@winsoft.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com,
	David Miller <davem@davemloft.net>
To: Krzysztof Kolasa <kkolasa@winsoft.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46596 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbaJLSqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2014 14:46:55 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so4397399pdj.4
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2014 11:46:54 -0700 (PDT)
In-Reply-To: <543AB655.6060603@winsoft.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-10-12 at 19:11 +0200, Krzysztof Kolasa wrote:
> This commit is the result of bisect my problem with window decoration in 
> gnome shell ( button, icons, colors etc.)
> 
> after revert this commit I don't have any problem with themes windows
> 
> a little impossible, commit to the network and affect the graphics might 
> be a problem with the allocation and release of memory
> 
> my system: 64bit Ubuntu 12.04.5 LTS, kernel next
> 
> latest AMD fglrx driver 14.301 ( problem tested and exist in 14.200 also )
> 
> Regards,
> 
> Krzysztof

Hi Krzysztof

This sounds quite strange to me. Some memory corruption might happen
regardless of networking changes, and this commit could uncover an
existing bug.

You might try different SLUB/SLAB choice, and try different debugging
SLUB/SLAB facilities.

With SLUB, skbuff_fclone_cache shares :t-0000512 kmem cache.
You could try slub_nomerge=1 for a start.
