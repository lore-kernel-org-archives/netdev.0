From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 07/13] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Tue, 29 Nov 2016 09:50:30 -0600
Message-ID: <2037427d-0ab6-9446-450d-21c34123c03b@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-8-grygorii.strashko@ti.com>
 <20161129100737.GF3110@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161129100737.GF3110-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 11/29/2016 04:07 AM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:03:31PM -0600, Grygorii Strashko wrote:
>> +int cpts_register(struct cpts *cpts)
>>  {
>>  	int err, i;
>>  
>> -	cpts->info = cpts_info;
>> -	spin_lock_init(&cpts->lock);
>> -
>> -	cpts->cc.read = cpts_systim_read;
>> -	cpts->cc.mask = CLOCKSOURCE_MASK(32);
>> -	cpts->cc_mult = mult;
>> -	cpts->cc.mult = mult;
>> -	cpts->cc.shift = shift;
>> -
>>  	INIT_LIST_HEAD(&cpts->events);
>>  	INIT_LIST_HEAD(&cpts->pool);
>>  	for (i = 0; i < CPTS_MAX_EVENTS; i++)
>>  		list_add(&cpts->pool_data[i].list, &cpts->pool);
>>  
>> -	cpts_clk_init(dev, cpts);
>> +	clk_enable(cpts->refclk);
>> +
>>  	cpts_write32(cpts, CPTS_EN, control);
>>  	cpts_write32(cpts, TS_PEND_EN, int_enable);
>>  
>> +	cpts->cc.mult = cpts->cc_mult;
> 
> It is not clear why you set cc.mult in a different place than
> cc.shift.  That isn't logical, but maybe later patches make it
> clear...

cc.mult has to be reloaded to original value each time CPTS is registered(restarted)
as it can be modified by cpts_ptp_adjfreq().

While cc.shift is static.



> 
>>  	timecounter_init(&cpts->tc, &cpts->cc, ktime_to_ns(ktime_get_real()));
>>  

[...]

>>  }
>>  EXPORT_SYMBOL_GPL(cpts_unregister);
>>  
>> +struct cpts *cpts_create(struct device *dev, void __iomem *regs,
>> +			 u32 mult, u32 shift)
>> +{
>> +	struct cpts *cpts;
>> +
>> +	if (!regs || !dev)
>> +		return ERR_PTR(-EINVAL);
> 
> There is no need for this test, as the caller will always pass valid
> pointers.  (This isn't a user space library!)
> 
ok

-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
