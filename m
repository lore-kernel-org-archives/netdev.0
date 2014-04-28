From: George Cherian <george.cherian@ti.com>
Subject: Re: [PATCH 1/6] drivers: net: cpts: Remove hardcoded clock name for
 CPTS
Date: Mon, 28 Apr 2014 20:15:35 +0530
Message-ID: <535E698F.7060104@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
 <1398658225-25873-2-git-send-email-george.cherian@ti.com>
 <20140428143115.GC30292@saruman.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, mugunthanvnm@ti.com, tony@atomide.com,
 ast@plumgrid.com, mturquette@linaro.org, jeffrey.t.kirsher@intel.com,
 tklauser@distanz.ch, devicetree@vger.kernel.org, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, richardcochran@gmail.com, robh+dt@kernel.org,
 bhutchings@solarflare.com, linux@arm.linux.org.uk, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, zonque@gmail.com, t-kristo@ti.com,
 dborkman@redhat.com, bcousson@baylibre.com, galak@codeaurora.org,
 mpa@pengutronix.de, davem@davemloft.net
To: <balbi@ti.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140428143115.GC30292@saruman.home>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 4/28/2014 8:01 PM, Felipe Balbi wrote:
> On Mon, Apr 28, 2014 at 09:40:20AM +0530, George Cherian wrote:
>> CPTS refclk name is hardcoded, which makes it fail in case of DRA7x
>> Remove the hardcoded clock name for CPTS refclk and get the same from DT.
>>
>> Signed-off-by: George Cherian <george.cherian@ti.com>
>> ---
>>   drivers/net/ethernet/ti/cpts.c | 11 ++++-------
>>   1 file changed, 4 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
>> index 2435139..0b6f6f7 100644
>> --- a/drivers/net/ethernet/ti/cpts.c
>> +++ b/drivers/net/ethernet/ti/cpts.c
>> @@ -236,13 +236,11 @@ static void cpts_overflow_check(struct work_struct *work)
>>   	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
>>   }
>>   
>> -#define CPTS_REF_CLOCK_NAME "cpsw_cpts_rft_clk"
>> -
>> -static void cpts_clk_init(struct cpts *cpts)
>> +static void cpts_clk_init(struct device *dev, struct cpts *cpts)
>>   {
>> -	cpts->refclk = clk_get(NULL, CPTS_REF_CLOCK_NAME);
>> +	cpts->refclk = devm_clk_get(dev, "cpts");
>>   	if (IS_ERR(cpts->refclk)) {
>> -		pr_err("Failed to clk_get %s\n", CPTS_REF_CLOCK_NAME);
>> +		pr_err("Failed to get cpts refclk\n");
> now you have a dev pointer as argument, how about converting this to
> dev_err() ?
Yep will do.. in next version.


-- 
-George
