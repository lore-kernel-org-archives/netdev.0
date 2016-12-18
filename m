From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: fix memory leak of a qed_spq_entry on error
 failure paths
Date: Sun, 18 Dec 2016 10:37:17 -0500 (EST)
Message-ID: <20161218.103717.315074604605472721.davem@davemloft.net>
References: <20161216125039.20969-1-colin.king@canonical.com>
        <BL2PR07MB2306151726E6A6E95702776B8D9E0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ariel.Elior@cavium.com,
        Tomer.Tayar@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR07MB2306151726E6A6E95702776B8D9E0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Sun, 18 Dec 2016 06:33:50 +0000

>> From: Colin Ian King <colin.king@canonical.com>
>> 
>> A qed_spq_entry entry is allocated by qed_sp_init_request but is not kfree'd
>> if an error occurs, causing a memory leak. Fix this by kfree'ing it and also
>> setting *pp_ent to NULL to be safe.
>> 
>> Found with static analysis by CoverityScan, CIDs 1389468-1389470
>> 
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ...
>> +err:
>> +	kfree(*pp_ent);
>> +	*pp_ent = NULL;
>> +
>> +	return rc;
>>  }
> 
> Hi Colin - thanks for this.
> It would have been preferable to return the previously allocated spq entry.
> I.e., do:
> 
> +err:
> +	qed_spq_return_entry(p_hwfn, *pp_ent);
> +	*pp_ent = NULL;
> +	return rc;

Looking at this last night, I came to the same conclusion.
