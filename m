From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: dev_map_alloc() shouldn't return NULL
Date: Sat, 22 Jul 2017 12:07:09 -0700
Message-ID: <5973A25D.8030903@gmail.com>
References: <20170722074004.3abeucov67n3sbqs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33818 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdGVTHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 15:07:19 -0400
In-Reply-To: <20170722074004.3abeucov67n3sbqs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2017 12:40 AM, Dan Carpenter wrote:
> We forgot to set the error code on two error paths which means that we
> return ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is
> not expecting that and will have a NULL dereference.
> 
> Fixes: 546ac1ffb70d ("bpf: add devmap, a map for storing net device references")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
> index 899364d097f5..d439ee0eadb1 100644
> --- a/kernel/bpf/devmap.c
> +++ b/kernel/bpf/devmap.c
> @@ -114,6 +114,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
>  	if (err)
>  		goto free_dtab;
>  
> +	err = -ENOMEM;
>  	/* A per cpu bitfield with a bit per possible net device */
>  	dtab->flush_needed = __alloc_percpu(
>  				BITS_TO_LONGS(attr->max_entries) *
> 

Thanks.

Acked-by: John Fastabend <john.fastabend@gmail.com>
