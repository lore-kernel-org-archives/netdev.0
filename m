From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 23 Sep 2015 22:51:54 +0200
Message-ID: <560310EA.2070805@intel.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <1443033714.74600.18.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	grant.likely@linaro.org, Suravee.Suthikulpanit@amd.com,
	Catalin.Marinas@arm.com
To: David Woodhouse <dwmw2@infradead.org>,
	Jeremy Linton <jeremy.linton@arm.com>,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35072 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195AbbIWUv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 16:51:59 -0400
In-Reply-To: <1443033714.74600.18.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/2015 8:41 PM, David Woodhouse wrote:
> On Wed, 2015-08-12 at 17:06 -0500, Jeremy Linton wrote:
>>   
>> +static const struct acpi_device_id smsc911x_acpi_match[] = {
>> +       { "ARMH9118", 0 },
>> +       { }
>> +};
>> +MODULE_DEVICE_TABLE(acpi, smsc911x_acpi_match);
>> +
>>   static struct platform_driver smsc911x_driver = {
>>          .probe = smsc911x_drv_probe,
>>          .remove = smsc911x_drv_remove,
>> @@ -2661,6 +2656,7 @@ static struct platform_driver smsc911x_driver =
>> {
>>                  .name   = SMSC_CHIPNAME,
>>                  .pm     = SMSC911X_PM_OPS,
>>                  .of_match_table = of_match_ptr(smsc911x_dt_ids),
>> +               .acpi_match_table = ACPI_PTR(smsc911x_acpi_match),
>>          },
>>   };
> Hm, surely you shouldn't need this part? If the ACPI device has a HID
> of PRP0001, and an appropriate "compatible" property, then it ought to
> be loaded anyway. If that doesn't work, we should fix that.

But if the device ID is assigned already, why would it hurt to actually 
use it?

Thanks,
Rafael
