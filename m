From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 03 Mar 2008 10:53:52 +0100
Message-ID: <47CBCAB0.2040604@cosmosbay.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093624.GC15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Christoph Lameter <clameter@engr.sgi.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.48]:48182 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758952AbYCCJyQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 04:54:16 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2113.orange.fr (SMTP Server) with ESMTP id 15FD31C000AC
	for <netdev@vger.kernel.org>; Mon,  3 Mar 2008 08:25:14 +0100 (CET)
In-Reply-To: <20080303093624.GC15091@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Piggin a =E9crit :
> Use SLAB_SMP_ALIGN in a few places.
>
>  =20

I dont understand why you added SLAB_SMP_ALIGN, without removing=20
SLAB_HWCACHE_ALIGN on these places.

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/fs/block_dev.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/fs/block_dev.c
> +++ linux-2.6/fs/block_dev.c
> @@ -332,8 +332,8 @@ void __init bdev_cache_init(void)
>  {
>  	int err;
>  	bdev_cachep =3D kmem_cache_create("bdev_cache", sizeof(struct bdev_=
inode),
> -			0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
> -				SLAB_MEM_SPREAD|SLAB_PANIC),
> +			0, (SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|
> +			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_PANIC),
>  			init_once);
>  	err =3D register_filesystem(&bd_type);
>  	if (err)
> Index: linux-2.6/kernel/fork.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/fork.c
> +++ linux-2.6/kernel/fork.c
> @@ -1547,23 +1547,23 @@ void __init proc_caches_init(void)
>  {
>  	sighand_cachep =3D kmem_cache_create("sighand_cache",
>  			sizeof(struct sighand_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
> +			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
>  			sighand_ctor);
>  	signal_cachep =3D kmem_cache_create("signal_cache",
>  			sizeof(struct signal_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
>  	files_cachep =3D kmem_cache_create("files_cache",
>  			sizeof(struct files_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
>  	fs_cachep =3D kmem_cache_create("fs_cache",
>  			sizeof(struct fs_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
>  	vm_area_cachep =3D kmem_cache_create("vm_area_struct",
>  			sizeof(struct vm_area_struct), 0,
>  			SLAB_PANIC, NULL);
>  	mm_cachep =3D kmem_cache_create("mm_struct",
>  			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
>  }
> =20
>  /*
> Index: linux-2.6/kernel/pid.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/pid.c
> +++ linux-2.6/kernel/pid.c
> @@ -526,5 +526,5 @@ void __init pidmap_init(void)
>  	atomic_dec(&init_pid_ns.pidmap[0].nr_free);
> =20
>  	init_pid_ns.pid_cachep =3D KMEM_CACHE(pid,
> -			SLAB_HWCACHE_ALIGN | SLAB_PANIC);
> +			SLAB_HWCACHE_ALIGN | SLAB_SMP_ALIGN | SLAB_PANIC);
>  }
> Index: linux-2.6/kernel/user.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/user.c
> +++ linux-2.6/kernel/user.c
> @@ -503,7 +503,7 @@ static int __init uid_cache_init(void)
>  	int n;
> =20
>  	uid_cachep =3D kmem_cache_create("uid_cache", sizeof(struct user_st=
ruct),
> -			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +			0, SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
> =20
>  	for(n =3D 0; n < UIDHASH_SZ; ++n)
>  		INIT_HLIST_HEAD(init_user_ns.uidhash_table + n);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20




