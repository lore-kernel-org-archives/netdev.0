From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] prevent the read ahead of /proc/slabinfo in ss
Date: Mon, 09 Feb 2015 08:07:29 -0800
Message-ID: <1423498049.31870.192.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423481830-9599-1-git-send-email-brytonlee01@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Bryton Lee <brytonlee01@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:49315 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933503AbbBIQHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 11:07:32 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so17306995igb.2
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 08:07:31 -0800 (PST)
In-Reply-To: <1423481830-9599-1-git-send-email-brytonlee01@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-09 at 19:37 +0800, Bryton Lee wrote:
> ss reads ahead of /proc/slabinfo whatever slabstat will be used or not in future.
> this will cause huge system delay when the kernel hires SLAB allocator(SLUB allocator is ok). when program reads
> /proc/slabinfo, it will call s_show() in SLAB allocator level, and s_show() calls spin_lock_irq(&l3->list_lock) 
> then iterate on whole three lists. if one slab has about 900 million objects (for example dentry),
> it will cause more than 1000ms delay. 
> 
> so this patch prevents the read ahead of /proc/slabinfo, ss runs with most parameters not using slabstat at all.

Indeed, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
