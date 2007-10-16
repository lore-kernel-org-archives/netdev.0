From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: atm: panic when loading clip 2nd time
Date: Tue, 16 Oct 2007 14:33:38 -0700
Message-ID: <29495f1d0710161433h6e4e90a6r32c89c2a89af2f90@mail.gmail.com>
References: <47152758.5000900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, chas@cmf.nrl.navy.mil
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:38828 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934112AbXJPVdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 17:33:40 -0400
Received: by ug-out-1314.google.com with SMTP id z38so167415ugc
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 14:33:39 -0700 (PDT)
In-Reply-To: <47152758.5000900@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/07, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 2.6.23-git7, using SLAB (not SLUB) [config attached]:
>
> # modprobe clip
> # rmmod clip
> # modprobe clip
>
> results in panic:
>
> kmem_cache_create: duplicate cache clip_arp_cache
>
> Call Trace:
>  [<ffffffff8028c682>] kmem_cache_create+0x3bf/0x3fd
>  [<ffffffff8046ba1d>] neigh_table_init_no_netlink+0x6c/0x242
>  [<ffffffff8800a010>] :clip:atm_clip_init+0x10/0x8a
>  [<ffffffff80258ba4>] sys_init_module+0x146c/0x15cd
>  [<ffffffff8046be0a>] neigh_lookup+0x0/0xd5
>  [<ffffffff8020ef44>] syscall_trace_enter+0x95/0x99
>  [<ffffffff8020beec>] tracesys+0xdc/0xe1
>
> Kernel panic - not syncing: kmem_cache_create(): failed to create slab `clip_arp_cache'

>From a quick read through the code, looks like
net/core/neighbour.c:neigh_table_clear() needs a kmem_cache_destroy()?

I only see three callers of neight_table_clear() and they all seem to
be in exit routines, so that should be safe?

-Nish
