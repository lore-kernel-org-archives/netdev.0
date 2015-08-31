From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net/smsc911x: Fix deferred probe for interrupt
Date: Mon, 31 Aug 2015 17:03:10 +0300
Message-ID: <55E45E9E.1090900@ti.com>
References: <1440787815-24655-1-git-send-email-tony@atomide.com>
 <55E22540.3060307@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Tony Lindgren <tony@atomide.com>,
	David Miller <davem@davemloft.net>,
	Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:58725 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbbHaODW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 10:03:22 -0400
In-Reply-To: <55E22540.3060307@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2015 12:33 AM, Sergei Shtylyov wrote:
> Hello.
> 
> On 8/28/2015 9:50 PM, Tony Lindgren wrote:
> 
>> The interrupt handler may not be available when smsc911x probes if the
>> interrupt handler is a GPIO controller for example. Let's fix that
>> by adding handling for -EPROBE_DEFER.
> 
>> Cc: Steve Glendinning <steve.glendinning@shawell.net>
>> Signed-off-by: Tony Lindgren <tony@atomide.com>
>> ---
>>   drivers/net/ethernet/smsc/smsc911x.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/smsc/smsc911x.c 
>> b/drivers/net/ethernet/smsc/smsc911x.c
>> index 959aeea..cb9f166f 100644
>> --- a/drivers/net/ethernet/smsc/smsc911x.c
>> +++ b/drivers/net/ethernet/smsc/smsc911x.c
>> @@ -2435,7 +2435,10 @@ static int smsc911x_drv_probe(struct 
>> platform_device *pdev)
>>       res_size = resource_size(res);
>>
>>       irq = platform_get_irq(pdev, 0);
>> -    if (irq <= 0) {
>> +    if (irq == -EPROBE_DEFER) {
>> +        retval = -EPROBE_DEFER;
>> +        goto out_0;
>> +    } else if (irq <= 0) {
>>           pr_warn("Could not allocate irq resource\n");
>>           retval = -ENODEV;
> 
>     I'd propagate the error code from platfrom_get_irq() instead (in 
> fact, I've submitted a couple of such patches yesterday and they have 
> been already merged).

Have you paid some attention on current platform_get_irq_() implementation?

The platform_get_irq() can return 0 in case of DT-boot.


-- 
regards,
-grygorii
