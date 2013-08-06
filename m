From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 3/3] net: core: fix wrong linkage for ptype_base
 and ptype_all symbols
Date: Tue, 06 Aug 2013 10:13:15 +0200
Message-ID: <5200B01B.9080705@redhat.com>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com> <1375774371-831-3-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab3HFINT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 04:13:19 -0400
In-Reply-To: <1375774371-831-3-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2013 09:32 AM, Jean Sacren wrote:
> In commit 900ff8c6 ("net: move procfs code to net/core/net-procfs.c"),
> it changed the correct linkage of ptype_base and ptype_all symbols to
> the wrong one in net/core/dev.c, yet failed to change to the correct
> linkage of those two in net/core/net-procfs.c.
>
> Fix the wrong linkage by setting static specifier to both sets of the
> symbols so that they could have coherent internal linkage by themselves
> to avoid interference with each other.

Ho? I do not think this is correct, what makes you think so?

The net-procfs.c usage of ptype_* is there to show current pf_packet users
via seq_files in procfs. Your patch will just break this.

> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> ---
>   net/core/dev.c        | 4 ++--
>   net/core/net-procfs.c | 4 ++--
>   2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index dfd9f5d..d85e5e1 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -142,8 +142,8 @@
>
>   static DEFINE_SPINLOCK(ptype_lock);
>   static DEFINE_SPINLOCK(offload_lock);
> -struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
> -struct list_head ptype_all __read_mostly;	/* Taps */
> +static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
> +static struct list_head ptype_all __read_mostly;	/* Taps */
>   static struct list_head offload_base __read_mostly;
>
>   /*
> diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
> index 2bf8329..e57cd63 100644
> --- a/net/core/net-procfs.c
> +++ b/net/core/net-procfs.c
> @@ -9,8 +9,8 @@
>   #define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
>   #define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
>
> -extern struct list_head ptype_all __read_mostly;
> -extern struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
> +static struct list_head ptype_all __read_mostly;
> +static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
>
>   static inline struct net_device *dev_from_same_bucket(struct seq_file *seq, loff_t *pos)
>   {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
