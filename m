From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH][V2] qed: fix memory leak of a qed_spq_entry on error
 failure paths
Date: Wed, 21 Dec 2016 14:28:01 +0000
Message-ID: <2f9e0ee7-4c59-1b4b-ebeb-13ca52aa912a@canonical.com>
References: <20161220114424.11244-1-colin.king@canonical.com>
 <BL2PR07MB230615AAE3CF67DEBC6083778D930@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR07MB230615AAE3CF67DEBC6083778D930@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/12/16 13:29, Mintz, Yuval wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> A qed_spq_entry entry is allocated by qed_sp_init_request but is not kfree'd
>> if an error occurs, causing a memory leak. Fix this by returning the previously
>> allocated spq entry and also setting *pp_ent to NULL to be safe.
>>
>> Thanks to Yuval Mintz for suggestions on how to improve my original fix.
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> We've given it a more thorough look, and apparently this isn't the correct fix.
> So I'll start by saying sorry for making you send this V2 needlessly.
> 
> It boils down to the fact there are two kinds of SPQ entries -
> Those originating from the 'free_pool' and those from the 'unlimited_pending'.
> Only those originating from the free_pool should be returned
> using the qed_spq_return_entry(), as only those actually point to a valid
> dma-mapped memory where FW expects to find the entries;
> Returning the other kind would lead to assertions later,
> as driver would post a ramrod to FW which actually points to address 0.
> 
> Looking at the error flows, it seems possible this isn't the only faulty
> error flow in the SPQ. I suggest you'd drop this and we'll take it from
> here [although if you really have the urge to continue - please do].
> 
> Thanks,
> Yuval
> 
> 
Sure, lets drop my fixes, I'm out of time on this for 2016 anyhow.

Colin
