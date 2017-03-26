From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RESEND PATCH 2/3] net: hns: avoid gcc-7.0.1 warning for
 uninitialized data
Date: Sat, 25 Mar 2017 20:05:53 -0700 (PDT)
Message-ID: <20170325.200553.661929780985796313.davem@davemloft.net>
References: <20170324220250.2193128-1-arnd@arndb.de>
        <20170324220250.2193128-4-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324220250.2193128-4-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Fri, 24 Mar 2017 23:02:50 +0100

> hns_dsaf_set_mac_key() calls dsaf_set_field() on an uninitialized field,
> which will then change only a few of its bits, causing a warning with
> the latest gcc:
> 
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_set_mac_uc_entry':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    (origin) &= (~(mask)); \
>             ^~
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_set_mac_mc_entry':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_add_mac_mc_port':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_del_mac_entry':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_rm_mac_addr':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_del_mac_mc_port':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_get_mac_uc_entry':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_get_mac_mc_entry':
> hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The code is actually correct since we always set all 16 bits of the
> port_vlan field, but gcc correctly points out that the first
> access does contain uninitialized data.
> 
> This initializes the field to zero first before setting the
> individual bits.
> 
> Fixes: 5483bfcb169c ("net: hns: modify tcam table and set mac key")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
