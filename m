From: Madhu Challa <challa@noironetworks.com>
Subject: Re: [net-next PATCH 1/2] fib_trie: Avoid NULL pointer if local table
 is not allocated
Date: Thu, 12 Mar 2015 15:31:17 -0700
Message-ID: <CAN_zqfOpFY_GDk6DJO1JqqVXsFMpT0my9PzdVB03twAGAz6gmg@mail.gmail.com>
References: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
	<20150312214623.1133.48565.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36215 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbCLWbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:31:18 -0400
Received: by padfa1 with SMTP id fa1so24066925pad.3
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 15:31:17 -0700 (PDT)
In-Reply-To: <20150312214623.1133.48565.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I verified it. Looking good. Thanks a lot !

On Thu, Mar 12, 2015 at 2:46 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> The function fib_unmerge assumed the local table had already been
> allocated.  If that is not the case however when custom rules are applied
> then this can result in a NULL pointer dereference.
>
> In order to prevent this we must check the value of the local table pointer
> and if it is NULL simply return 0 as there is no local table to separate
> from the main.
>
> Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")
> Reported-by: Madhu Challa <challa@noironetworks.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  net/ipv4/fib_frontend.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index c1caf9d..e5b6b05 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -156,9 +156,12 @@ int fib_unmerge(struct net *net)
>  {
>         struct fib_table *old, *new;
>
> +       /* attempt to fetch local table if it has been allocated */
>         old = fib_get_table(net, RT_TABLE_LOCAL);
> -       new = fib_trie_unmerge(old);
> +       if (!old)
> +               return 0;
>
> +       new = fib_trie_unmerge(old);
>         if (!new)
>                 return -ENOMEM;
>
>
