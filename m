From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Subject: Re: [PATCH 2/3] i40e: Add XDP_TX support
Date: Thu, 8 Dec 2016 21:22:31 +0100
Message-ID: <CAJ+HfNhG=XegU2Qyj6brL2o0X+KHUg=Q1LnwaQcXVxunS-HN3g@mail.gmail.com>
References: <20161208170022.11555-3-bjorn.topel@gmail.com> <201612090331.1UJP1l3g%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: kbuild-all@01.org, jeffrey.t.kirsher@intel.com,
        intel-wired-lan@lists.osuosl.org,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        john.r.fastabend@intel.com, magnus.karlsson@intel.com,
        netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36215 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752726AbcLHUWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 15:22:32 -0500
Received: by mail-yw0-f195.google.com with SMTP id r204so35655110ywb.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 12:22:32 -0800 (PST)
In-Reply-To: <201612090331.1UJP1l3g%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-12-08 20:20 GMT+01:00 kbuild test robot <lkp@intel.com>:
> Hi Bj=C3=B6rn,
>
> [auto build test ERROR on next-20161208]
> [cannot apply to jkirsher-next-queue/dev-queue v4.9-rc8 v4.9-rc7 v4.9-rc6=
 v4.9-rc8]
> [if your patch is applied to the wrong git tree, please drop us a note to=
 help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Bj-rn-T-pel/i40e-Support=
-for-XDP/20161209-013138
> config: sparc64-allmodconfig (attached as .config)
> compiler: sparc64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.g=
it/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=3Dsparc64
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from include/linux/cache.h:4:0,
>                     from include/linux/printk.h:8,
>                     from include/linux/kernel.h:13,
>                     from include/linux/list.h:8,
>                     from include/linux/timer.h:4,
>                     from include/linux/workqueue.h:8,
>                     from include/linux/bpf.h:11,
>                     from drivers/net/ethernet/intel/i40e/i40e_txrx.c:27:
>    drivers/net/ethernet/intel/i40e/i40e_txrx.c: In function 'i40e_try_fli=
p_rx_page':
>>> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1613:32: error: 'size' unde=
clared (first use in this function)
>      unsigned int truesize =3D ALIGN(size, L1_CACHE_BYTES);
>                                    ^
>    include/uapi/linux/kernel.h:10:41: note: in definition of macro '__ALI=
GN_KERNEL_MASK'
>     #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
>                                             ^
>    include/linux/kernel.h:49:22: note: in expansion of macro '__ALIGN_KER=
NEL'
>     #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
>                          ^~~~~~~~~~~~~~
>>> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1613:26: note: in expansion=
 of macro 'ALIGN'
>      unsigned int truesize =3D ALIGN(size, L1_CACHE_BYTES);
>                              ^~~~~
>    drivers/net/ethernet/intel/i40e/i40e_txrx.c:1613:32: note: each undecl=
ared identifier is reported only once for each function it appears in
>      unsigned int truesize =3D ALIGN(size, L1_CACHE_BYTES);
>                                    ^
>    include/uapi/linux/kernel.h:10:41: note: in definition of macro '__ALI=
GN_KERNEL_MASK'
>     #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
>                                             ^
>    include/linux/kernel.h:49:22: note: in expansion of macro '__ALIGN_KER=
NEL'
>     #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
>                          ^~~~~~~~~~~~~~
>>> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1613:26: note: in expansion=
 of macro 'ALIGN'
>      unsigned int truesize =3D ALIGN(size, L1_CACHE_BYTES);
>                              ^~~~~
>
> vim +/size +1613 drivers/net/ethernet/intel/i40e/i40e_txrx.c
>
>   1607   */
>   1608  static bool i40e_try_flip_rx_page(struct i40e_rx_buffer *rx_buffe=
r)
>   1609  {
>   1610  #if (PAGE_SIZE < 8192)
>   1611          unsigned int truesize =3D I40E_RXBUFFER_2048;
>   1612  #else
>> 1613          unsigned int truesize =3D ALIGN(size, L1_CACHE_BYTES);
>   1614          unsigned int last_offset =3D PAGE_SIZE - I40E_RXBUFFER_20=
48;
>   1615  #endif
>   1616
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://lists.01.org/pipermail/kbuild-all                   Intel Corpora=
tion


Ick. I'll respin this.


Bj=C3=B6rn
