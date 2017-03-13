From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 06:07:54 -0700
Message-ID: <1489410474.28631.75.camel@edumazet-glaptop3.roam.corp.google.com>
References: <201703132013.YIF2VUWv%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36733 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750975AbdCMNH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 09:07:57 -0400
Received: by mail-pg0-f66.google.com with SMTP id 25so18000402pgy.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 06:07:56 -0700 (PDT)
In-Reply-To: <201703132013.YIF2VUWv%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 20:50 +0800, kbuild test robot wrote:
> Hi Eric,
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/mlx4-Better-use-of-order-0-pages-in-RX-path/20170313-191100
> config: x86_64-randconfig-s5-03131942 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    drivers/net/ethernet/mellanox/mlx4/en_rx.c:622:12: warning: 'struct iphdr' declared inside parameter list will not be visible outside of this definition or declaration
>         struct iphdr *iph)
>                ^~~~~
>    In file included from include/linux/swab.h:4:0,
>                     from include/uapi/linux/byteorder/little_endian.h:12,
>                     from include/linux/byteorder/little_endian.h:4,
>                     from arch/x86/include/uapi/asm/byteorder.h:4,
>                     from include/asm-generic/bitops/le.h:5,
>                     from arch/x86/include/asm/bitops.h:517,
>                     from include/linux/bitops.h:36,
>                     from include/linux/kernel.h:10,
>                     from include/linux/list.h:8,
>                     from include/linux/timer.h:4,
>                     from include/linux/workqueue.h:8,
>                     from include/linux/bpf.h:12,
>                     from drivers/net/ethernet/mellanox/mlx4/en_rx.c:34:
>    drivers/net/ethernet/mellanox/mlx4/en_rx.c: In function 'get_fixed_ipv4_csum':
>    drivers/net/ethernet/mellanox/mlx4/en_rx.c:627:36: error: dereferencing pointer to incomplete type 'struct iphdr'
>      length_for_csum = (be16_to_cpu(iph->tot_len) - (iph->ihl << 2));
>                                        ^
>    include/uapi/linux/swab.h:100:54: note: in definition of macro '__swab16'
>     #define __swab16(x) (__u16)__builtin_bswap16((__u16)(x))
>                                                          ^
> >> include/linux/byteorder/generic.h:96:21: note: in expansion of macro '__be16_to_cpu'
>     #define be16_to_cpu __be16_to_cpu
>                         ^~~~~~~~~~~~~
> >> drivers/net/ethernet/mellanox/mlx4/en_rx.c:627:21: note: in expansion of macro 'be16_to_cpu'
>      length_for_csum = (be16_to_cpu(iph->tot_len) - (iph->ihl << 2));
>                         ^~~~~~~~~~~
> 
> vim +/be16_to_cpu +627 drivers/net/ethernet/mellanox/mlx4/en_rx.c

I removed the include <net/budy_poll.h>

It seems we need <net/ip.h>.
