From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: hns: fix ethtool_get_strings overflow in
 hns driver
Date: Tue, 02 May 2017 15:08:32 -0400 (EDT)
Message-ID: <20170502.150832.1539345702174708842.davem@davemloft.net>
References: <20170502024652.39536-1-lixiaoping3@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, lipeng321@huawei.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, mbrugger@suse.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: lixiaoping3@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdEBTIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:08:34 -0400
In-Reply-To: <20170502024652.39536-1-lixiaoping3@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timmy Li <lixiaoping3@huawei.com>
Date: Tue, 2 May 2017 10:46:52 +0800

> hns_get_sset_count() returns HNS_NET_STATS_CNT and the data space allocated
> is not enough for ethtool_get_strings(), which will cause random memory
> corruption.
> 
> When SLAB and DEBUG_SLAB are both enabled, memory corruptions like the
> the following can be observed without this patch:
> [   43.115200] Slab corruption (Not tainted): Acpi-ParseExt start=ffff801fb0b69030, len=80
> [   43.115206] Redzone: 0x9f911029d006462/0x5f78745f31657070.
> [   43.115208] Last user: [<5f7272655f746b70>](0x5f7272655f746b70)
> [   43.115214] 010: 70 70 65 31 5f 74 78 5f 70 6b 74 00 6b 6b 6b 6b  ppe1_tx_pkt.kkkk
> [   43.115217] 030: 70 70 65 31 5f 74 78 5f 70 6b 74 5f 6f 6b 00 6b  ppe1_tx_pkt_ok.k
> [   43.115218] Next obj: start=ffff801fb0b69098, len=80
> [   43.115220] Redzone: 0x706d655f6f666966/0x9f911029d74e35b.
> [   43.115229] Last user: [<ffff0000084b11b0>](acpi_os_release_object+0x28/0x38)
> [   43.115231] 000: 74 79 00 6b 6b 6b 6b 6b 70 70 65 31 5f 74 78 5f  ty.kkkkkppe1_tx_
> [   43.115232] 010: 70 6b 74 5f 65 72 72 5f 63 73 75 6d 5f 66 61 69  pkt_err_csum_fai
> 
> Signed-off-by: Timmy Li <lixiaoping3@huawei.com>
> ---
> Changelog:
> 
> v1 -> v2:
>     * Remove unnecessary parenthesis

Applied, thank you.
