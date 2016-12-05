From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ethernet: qlogic: set error code on failure
Date: Mon, 05 Dec 2016 14:55:16 -0500 (EST)
Message-ID: <20161205.145516.846922633542908155.davem@davemloft.net>
References: <1480830833-5084-1-git-send-email-bianpan201603@163.com>
        <BL2PR07MB2306060C02F0A19BD735EBE28D800@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bianpan201603@163.com, netdev@vger.kernel.org,
        Ariel.Elior@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbcLEUE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:04:56 -0500
In-Reply-To: <BL2PR07MB2306060C02F0A19BD735EBE28D800@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Sun, 4 Dec 2016 07:29:58 +0000

>> From: Pan Bian <bianpan2016@163.com>
>> 
>> When calling dma_mapping_error(), the value of return variable rc is 0.
>> And when the call returns an unexpected value, rc is not set to a negative
>> errno. Thus, it will return 0 on the error path, and its callers cannot detect
>> the bug. This patch fixes the bug, assigning "-ENOMEM" to err.
>> 
>> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189041
>> 
>> Signed-off-by: Pan Bian <bianpan2016@163.com>
> 
> The title should have been "[PATCH net 1/1] qed: Set error code on failure".
> 
> But the fix itself is sound. Thanks.
> BTW, is -ENOMEM the right return code in case of DMA mapping errors?
> 
> Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.

Indeed, -ENOMEM is usually the right thing to use for DMA mapping errors.
Because usually the error is because we're run out of IOMMU resources
or similar.  And -ENOMEM is pretty much the error code which maps most
closely to that situation.
