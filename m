From: Eric Dumazet <edumazet@google.com>
Subject: Re: [net-next:master 200/201] net/ipv4/fib_trie.c:293:3: error:
 implicit declaration of function 'vfree'
Date: Tue, 26 May 2015 21:21:52 -0700
Message-ID: <CANn89iJyZiBZfTzQXMRmxa4sYYmbP1SM194vxuk_h3+PPMzhxA@mail.gmail.com>
References: <201505271204.NKEoVJFK%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, netdev <netdev@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35074 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbE0EVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 00:21:53 -0400
Received: by iesa3 with SMTP id a3so4923199ies.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 21:21:53 -0700 (PDT)
In-Reply-To: <201505271204.NKEoVJFK%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few vmalloc() users forgot to include <linux/vmalloc.h>,
which used to be included from include/net/inet_hashtables.h

Thanks for the report, I'll send fixes.

On Tue, May 26, 2015 at 9:12 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   d6a4e26afb80c049e7f94e1b7b506dcda61eee88
> commit: 095dc8e0c3686d586a01a50abc3e1bb9ac633054 [200/201] tcp: fix/cleanup inet_ehash_locks_alloc()
> config: powerpc-defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 095dc8e0c3686d586a01a50abc3e1bb9ac633054
>   # save the attached .config to linux build tree
>   make.cross ARCH=powerpc
>
> All error/warnings:
>
>    net/ipv4/fib_trie.c: In function '__node_free_rcu':
>>> net/ipv4/fib_trie.c:293:3: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>       vfree(n);
>       ^
>    net/ipv4/fib_trie.c: In function 'tnode_alloc':
>>> net/ipv4/fib_trie.c:312:3: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>       return vzalloc(size);
>       ^
>>> net/ipv4/fib_trie.c:312:3: warning: return makes pointer from integer without a cast
>    cc1: some warnings being treated as errors
> --
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_create_chap_list':
>>> drivers/scsi/qla4xxx/ql4_os.c:617:3: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
>       ha->chap_list = vmalloc(chap_size);
>       ^
>>> drivers/scsi/qla4xxx/ql4_os.c:617:17: warning: assignment makes pointer from integer without a cast
>       ha->chap_list = vmalloc(chap_size);
>                     ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_mem_free':
>>> drivers/scsi/qla4xxx/ql4_os.c:4135:3: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>       vfree(ha->fw_dump);
>       ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_is_session_exists':
>>> drivers/scsi/qla4xxx/ql4_os.c:6340:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>      fw_tddb = vzalloc(sizeof(*fw_tddb));
>      ^
>>> drivers/scsi/qla4xxx/ql4_os.c:6340:10: warning: assignment makes pointer from integer without a cast
>      fw_tddb = vzalloc(sizeof(*fw_tddb));
>              ^
>>> drivers/scsi/qla4xxx/ql4_os.c:6348:11: warning: assignment makes pointer from integer without a cast
>      tmp_tddb = vzalloc(sizeof(*tmp_tddb));
>               ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_is_flash_ddb_exists':
>>> drivers/scsi/qla4xxx/ql4_os.c:6485:10: warning: assignment makes pointer from integer without a cast
>      fw_tddb = vzalloc(sizeof(*fw_tddb));
>              ^
>>> drivers/scsi/qla4xxx/ql4_os.c:6493:11: warning: assignment makes pointer from integer without a cast
>      tmp_tddb = vzalloc(sizeof(*tmp_tddb));
>               ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_get_ep_fwdb':
>>> drivers/scsi/qla4xxx/ql4_os.c:6556:11: warning: assignment makes pointer from integer without a cast
>      dst_addr = vmalloc(sizeof(*dst_addr));
>               ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_build_st_list':
>>> drivers/scsi/qla4xxx/ql4_os.c:6786:14: warning: assignment makes pointer from integer without a cast
>       st_ddb_idx = vzalloc(fw_idx_size);
>                  ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_build_nt_list':
>>> drivers/scsi/qla4xxx/ql4_os.c:7026:15: warning: assignment makes pointer from integer without a cast
>        nt_ddb_idx = vmalloc(fw_idx_size);
>                   ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_build_new_nt_list':
>>> drivers/scsi/qla4xxx/ql4_os.c:7122:14: warning: assignment makes pointer from integer without a cast
>       nt_ddb_idx = vmalloc(fw_idx_size);
>                  ^
>    drivers/scsi/qla4xxx/ql4_os.c: In function 'qla4xxx_sysfs_ddb_logout':
>>> drivers/scsi/qla4xxx/ql4_os.c:7732:13: warning: assignment makes pointer from integer without a cast
>      flash_tddb = vzalloc(sizeof(*flash_tddb));
>                 ^
>>> drivers/scsi/qla4xxx/ql4_os.c:7740:11: warning: assignment makes pointer from integer without a cast
>      tmp_tddb = vzalloc(sizeof(*tmp_tddb));
>               ^
>    cc1: some warnings being treated as errors
> --
>    drivers/scsi/qla4xxx/ql4_init.c: In function 'qla4xxx_alloc_fw_dump':
>>> drivers/scsi/qla4xxx/ql4_init.c:387:2: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
>      ha->fw_dump = vmalloc(ha->fw_dump_size);
>      ^
>>> drivers/scsi/qla4xxx/ql4_init.c:387:14: warning: assignment makes pointer from integer without a cast
>      ha->fw_dump = vmalloc(ha->fw_dump_size);
>                  ^
>    cc1: some warnings being treated as errors
> --
>    drivers/scsi/qla4xxx/ql4_83xx.c: In function 'qla4_83xx_copy_bootloader':
>>> drivers/scsi/qla4xxx/ql4_83xx.c:640:2: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
>      p_cache = vmalloc(size);
>      ^
>>> drivers/scsi/qla4xxx/ql4_83xx.c:640:10: warning: assignment makes pointer from integer without a cast
>      p_cache = vmalloc(size);
>              ^
>>> drivers/scsi/qla4xxx/ql4_83xx.c:671:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>      vfree(p_cache);
>      ^
>    drivers/scsi/qla4xxx/ql4_83xx.c: In function 'qla4_83xx_read_reset_template':
>>> drivers/scsi/qla4xxx/ql4_83xx.c:780:23: warning: assignment makes pointer from integer without a cast
>      ha->reset_tmplt.buff = vmalloc(QLA83XX_RESTART_TEMPLATE_SIZE);
>                           ^
>    cc1: some warnings being treated as errors
>
> vim +/vfree +293 net/ipv4/fib_trie.c
>
> 37fd30f2 Alexander Duyck   2014-12-31  287
> 56ca2adf Alexander Duyck   2015-03-06  288      if (!n->tn_bits)
> 37fd30f2 Alexander Duyck   2014-12-31  289              kmem_cache_free(trie_leaf_kmem, n);
> 56ca2adf Alexander Duyck   2015-03-06  290      else if (n->tn_bits <= TNODE_KMALLOC_MAX)
> 37fd30f2 Alexander Duyck   2014-12-31  291              kfree(n);
> 37fd30f2 Alexander Duyck   2014-12-31  292      else
> 37fd30f2 Alexander Duyck   2014-12-31 @293              vfree(n);
> 387a5487 Stephen Hemminger 2008-04-10  294  }
> 387a5487 Stephen Hemminger 2008-04-10  295
> 56ca2adf Alexander Duyck   2015-03-06  296  #define node_free(n) call_rcu(&tn_info(n)->rcu, __node_free_rcu)
> 37fd30f2 Alexander Duyck   2014-12-31  297
> dc35dbed Alexander Duyck   2015-03-06  298  static struct tnode *tnode_alloc(int bits)
> f0e36f8c Patrick McHardy   2005-07-05  299  {
> 1de3d87b Alexander Duyck   2015-03-04  300      size_t size;
> 1de3d87b Alexander Duyck   2015-03-04  301
> 1de3d87b Alexander Duyck   2015-03-04  302      /* verify bits is within bounds */
> 1de3d87b Alexander Duyck   2015-03-04  303      if (bits > TNODE_VMALLOC_MAX)
> 1de3d87b Alexander Duyck   2015-03-04  304              return NULL;
> 1de3d87b Alexander Duyck   2015-03-04  305
> 1de3d87b Alexander Duyck   2015-03-04  306      /* determine size and verify it is non-zero and didn't overflow */
> 1de3d87b Alexander Duyck   2015-03-04  307      size = TNODE_SIZE(1ul << bits);
> 1de3d87b Alexander Duyck   2015-03-04  308
> 2373ce1c Robert Olsson     2005-08-25  309      if (size <= PAGE_SIZE)
> 8d965444 Eric Dumazet      2008-01-13  310              return kzalloc(size, GFP_KERNEL);
> 15be75cd Stephen Hemminger 2008-04-10  311      else
> 7a1c8e5a Eric Dumazet      2010-11-20 @312              return vzalloc(size);
> 15be75cd Stephen Hemminger 2008-04-10  313  }
> 2373ce1c Robert Olsson     2005-08-25  314
> 35c6edac Alexander Duyck   2015-03-06  315  static inline void empty_child_inc(struct key_vector *n)
>
> :::::: The code at line 293 was first introduced by commit
> :::::: 37fd30f2da573c2625ed29561e5b8eb7b0258860 fib_trie: Merge tnode_free and leaf_free into node_free
>
> :::::: TO: Alexander Duyck <alexander.h.duyck@redhat.com>
> :::::: CC: David S. Miller <davem@davemloft.net>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
