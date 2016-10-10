From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] qed: Allow chance for fast ramrod
 completions
Date: Mon, 10 Oct 2016 03:17:24 -0400 (EDT)
Message-ID: <20161010.031724.182767468453485783.davem@davemloft.net>
References: <1476026738-26069-6-git-send-email-Yuval.Mintz@qlogic.com>
        <1476058115.28155.282.camel@edumazet-glaptop3.roam.corp.google.com>
        <BL2PR07MB230613EB6D587458F4143C678DDB0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751967AbcJJHRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 03:17:36 -0400
In-Reply-To: <BL2PR07MB230613EB6D587458F4143C678DDB0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Mon, 10 Oct 2016 06:33:05 +0000

> 
>> > +     while (iter_cnt--) {
>> > +             /* Validate we receive completion update */
>> >                smp_rmb();
>> >                if (comp_done->done == 1) {
>> >                        if (p_fw_ret)
>> >                                *p_fw_ret = comp_done->fw_return_code;
>> >                        return 0;
>> >                }
> 
>> Note that this smp_rmb() and accesses to ->done and ->fw_return_code are
>> racy.
> 
>> fw_return_code needs to be written _before_ done.
> 
> Thanks for catching this up.
> 
> Dave  - do you want me to re-spin for this?

Yes.
