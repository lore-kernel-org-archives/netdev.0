From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RESEND PATCH 1/3] net: hns: fix uninitialized data use
Date: Sat, 25 Mar 2017 20:05:46 -0700 (PDT)
Message-ID: <20170325.200546.249222967254161798.davem@davemloft.net>
References: <20170324220250.2193128-1-arnd@arndb.de>
        <20170324220250.2193128-3-arnd@arndb.de>
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
In-Reply-To: <20170324220250.2193128-3-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Fri, 24 Mar 2017 23:02:49 +0100

> When dev_dbg() is enabled, we print uninitialized data, as gcc-7.0.1
> now points out:
> 
> ethernet/hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_set_promisc_tcam':
> ethernet/hisilicon/hns/hns_dsaf_main.c:2947:75: error: 'tbl_tcam_data.low.val' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> ethernet/hisilicon/hns/hns_dsaf_main.c:2947:75: error: 'tbl_tcam_data.high.val' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> We also pass the data into hns_dsaf_tcam_mc_cfg(), which might later
> use it (not sure about that), so it seems safer to just always initialize
> the tbl_tcam_data structure.
> 
> Fixes: 1f5fa2dd1cfa ("net: hns: fix for promisc mode in HNS driver")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
