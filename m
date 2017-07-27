From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v3 1/3] ptp: introduce ptp auxiliary worker
Date: Thu, 27 Jul 2017 17:36:51 -0500
Message-ID: <74a827c9-467e-8791-3c97-9fc4c591435f@ti.com>
References: <20170726221138.12986-1-grygorii.strashko@ti.com>
 <20170726221138.12986-2-grygorii.strashko@ti.com>
 <20170727200829.cqe2gb6kl4lfzyux@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727200829.cqe2gb6kl4lfzyux@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/27/2017 03:08 PM, Richard Cochran wrote:
> On Wed, Jul 26, 2017 at 05:11:36PM -0500, Grygorii Strashko wrote:
>> @@ -217,6 +231,19 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
>>   	mutex_init(&ptp->pincfg_mux);
>>   	init_waitqueue_head(&ptp->tsev_wq);
>>   
>> +	if (ptp->info->do_aux_work) {
>> +		char *worker_name = kasprintf(GFP_KERNEL, "ptp%d", ptp->index);
> 
> This string is allocated but never freed.
> 
>> +		kthread_init_delayed_work(&ptp->aux_work, ptp_aux_kworker);
>> +		ptp->kworker = kthread_create_worker(0, worker_name ?
>> +						     worker_name : info->name);

Ops. Right need to add kfree(worker_name) here.


>> +		if (IS_ERR(ptp->kworker)) {
>> +			err = PTR_ERR(ptp->kworker);
>> +			pr_err("failed to create ptp aux_worker %d\n", err);
>> +			goto kworker_err;
>> +		}
>> +	}
>> +
> 
> Thanks,
> Richard
> 

-- 
regards,
-grygorii
