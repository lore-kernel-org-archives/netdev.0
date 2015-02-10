From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] prevent the read ahead of /proc/slabinfo in ss take 2
Date: Tue, 10 Feb 2015 15:37:42 +0300
Message-ID: <54D9FB96.6080401@cogentembedded.com>
References: <1423536360-5298-1-git-send-email-brytonlee01@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: Bryton Lee <brytonlee01@gmail.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:38255 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374AbbBJMhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 07:37:45 -0500
Received: by lamq1 with SMTP id q1so19872023lam.5
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 04:37:44 -0800 (PST)
In-Reply-To: <1423536360-5298-1-git-send-email-brytonlee01@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/10/2015 5:46 AM, Bryton Lee wrote:

> ss reads ahead of /proc/slabinfo whatever slabstat will be used or not in future.
> this will cause huge system delay when the kernel hires SLAB allocator(SLUB allocator is ok). when program reads
> /proc/slabinfo, it will call s_show() in SLAB allocator level, and s_show() calls spin_lock_irq(&l3->list_lock)
> then iterate on whole three lists. if one slab has about 900 million objects (for example dentry),
> it will cause more than 1000ms delay.

> so this patch prevents the read ahead of /proc/slabinfo, ss runs with most parameters not using slabstat at all.
> and this patch also change slabstat and slabstat_valid to static.

> Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
> ---
>   misc/ss.c | 11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)

> diff --git a/misc/ss.c b/misc/ss.c
> index 7fc0a99..5fa6259 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -616,7 +616,8 @@ struct slabstat
>   	int skbs;
>   };
>
> -struct slabstat slabstat;
> +static struct slabstat slabstat;
> +static int slabstat_valid = 0;

    No need to initialize to 0.

[...]

WBR, Sergei
