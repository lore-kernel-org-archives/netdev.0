From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 1/7] net: ethernet: ti: cpdma: am437x: allow descs to be
 plased in ddr
Date: Mon, 5 Dec 2016 11:57:42 -0600
Message-ID: <1fbfc83f-c48b-45da-6bc3-d37b2bb129b6@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
 <20161201233432.6182-2-grygorii.strashko@ti.com>
 <20161203.153419.482900037601991931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>, <nsekhar@ti.com>,
        <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <ivan.khoronzhuk@linaro.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203.153419.482900037601991931.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/03/2016 02:34 PM, David Miller wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> Date: Thu, 1 Dec 2016 17:34:26 -0600
> 
>> @@ -167,10 +167,10 @@ static struct cpdma_control_info controls[] = {
>>  
>>  /* various accessors */
>>  #define dma_reg_read(ctlr, ofs)		__raw_readl((ctlr)->dmaregs + (ofs))
>> -#define chan_read(chan, fld)		__raw_readl((chan)->fld)
>> +#define chan_read(chan, fld)		readl((chan)->fld)
>>  #define desc_read(desc, fld)		__raw_readl(&(desc)->fld)
>>  #define dma_reg_write(ctlr, ofs, v)	__raw_writel(v, (ctlr)->dmaregs + (ofs))
>> -#define chan_write(chan, fld, v)	__raw_writel(v, (chan)->fld)
>> +#define chan_write(chan, fld, v)	writel(v, (chan)->fld)
>>  #define desc_write(desc, fld, v)	__raw_writel((u32)(v), &(desc)->fld)
> 
> Unless you want to keep running into subtle errors all over the
> place wrt. register vs. memory write ordering, I strong suggest
> you use strongly ordered readl/writel for all register accesses.
> 
> I see no tangible, worthwhile, advantage to using these relaxed
> ordering primitives.  The only result is potential bugs.
> 
> People who use the relaxed ordering primitives properly are only
> doing so in extremely carefully coded sequences where a series
> of writes has no dependency on main memory operations and is
> explicitly completed with a barrier operation such as a read
> back of a register in the same device.
> 
> That's not at all what is going on here, instead the driver is wildly
> using relaxed ordered register accesses for basically everything.
> This is extremely unwise and it's why you ran into this bug in the
> first place.
> 
> Therefore, I absolutely require that you fix this by eliminating
> any and all usese of relaxed ordering I/O accessors in this driver.

Thanks for your comments - that's what I've tried first, but that decided
to find out minimal change which still works.

I'll update it. 

-- 
regards,
-grygorii
