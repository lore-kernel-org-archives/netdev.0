From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V4 PATCH 4/6] device property: Introduces device_dma_is_coherent()
Date: Wed, 20 May 2015 16:32:45 -0500
Message-ID: <555CFD7D.5090208@amd.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1431724994-21601-5-git-send-email-Suravee.Suthikulpanit@amd.com>
 <20150520102829.GB11498@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "rjw@rjwysocki.net" <rjw@rjwysocki.net>,
	"lenb@kernel.org" <lenb@kernel.org>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"msalter@redhat.com" <msalter@redhat.com>,
	"hanjun.guo@linaro.org" <hanjun.guo@linaro.org>,
	"al.stone@linaro.org" <al.stone@linaro.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"leo.duran@amd.com" <leo.duran@amd.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>,
	"netdev@vger.kernel.org"
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150520102829.GB11498@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/20/2015 5:28 AM, Will Deacon wrote:
> On Fri, May 15, 2015 at 10:23:12PM +0100, Suravee Suthikulpanit wrote:
>> Currently, device drivers, which support both OF and ACPI,
>> need to call two separate APIs, of_dma_is_coherent() and
>> acpi_dma_is_coherent()) to determine device coherency attribute.
>>
>> This patch simplifies this process by introducing a new device
>> property API, device_dma_is_coherent(), which calls the appropriate
>> interface based on the booting architecture.
>>
>> Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
>> CC: Rafael J. Wysocki <rjw@rjwysocki.net>
>> ---
>>   drivers/base/property.c  | 12 ++++++++++++
>>   include/linux/property.h |  2 ++
>>   2 files changed, 14 insertions(+)
>>
>> diff --git a/drivers/base/property.c b/drivers/base/property.c
>> index 1d0b116..8123c6e 100644
>> --- a/drivers/base/property.c
>> +++ b/drivers/base/property.c
>> @@ -14,6 +14,7 @@
>>   #include <linux/export.h>
>>   #include <linux/kernel.h>
>>   #include <linux/of.h>
>> +#include <linux/of_address.h>
>>   #include <linux/property.h>
>>
>>   /**
>> @@ -519,3 +520,14 @@ unsigned int device_get_child_node_count(struct device *dev)
>>   	return count;
>>   }
>>   EXPORT_SYMBOL_GPL(device_get_child_node_count);
>> +
>> +bool device_dma_is_coherent(struct device *dev)
>> +{
>> +	if (IS_ENABLED(CONFIG_OF) && dev->of_node)
>> +		return of_dma_is_coherent(dev->of_node);
>> +	else if (has_acpi_companion(dev))
>> +		return acpi_dma_is_coherent(acpi_node(dev->fwnode));
>
> I don't think you need the has_acpi_companion check, as acpi_node handles
> this and acpi_dma_is_coherent(NULL) returns false.
>
> Will
>
You are right.

Thanks,

Suravee
