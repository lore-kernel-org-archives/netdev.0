From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [V3 PATCH 3/5] device property: Introduces device_dma_is_coherent()
Date: Fri, 08 May 2015 13:27:00 -0700
Message-ID: <554D1C14.8080406@oracle.com>
References: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1431045436-8690-4-git-send-email-Suravee.Suthikulpanit@amd.com> <554C3790.4010407@oracle.com> <4329505.9FeAdJdNVY@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
	lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	thomas.lendacky@amd.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, arnd@arndb.de, msalter@redhat.com,
	hanjun.guo@linaro.org, al.stone@linaro.org,
	grant.likely@linaro.org, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18522 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219AbbEHU2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 16:28:01 -0400
In-Reply-To: <4329505.9FeAdJdNVY@vostro.rjw.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/2015 1:49 PM, Rafael J. Wysocki wrote:
> On Thursday, May 07, 2015 09:12:00 PM santosh.shilimkar@oracle.com wrote:
>> On 5/7/15 5:37 PM, Suravee Suthikulpanit wrote:
>>> Currently, device drivers, which support both OF and ACPI,
>>> need to call two separate APIs, of_dma_is_coherent() and
>>> acpi_dma_is_coherent()) to determine device coherency attribute.
>>>
>>> This patch simplifies this process by introducing a new device
>>> property API, device_dma_is_coherent(), which calls the appropriate
>>> interface based on the booting architecture.
>>>
>>> Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
>>> ---
>>>    drivers/base/property.c  | 12 ++++++++++++
>>>    include/linux/property.h |  2 ++
>>>    2 files changed, 14 insertions(+)
>>>
>>> diff --git a/drivers/base/property.c b/drivers/base/property.c
>>> index 1d0b116..8123c6e 100644
>>> --- a/drivers/base/property.c
>>> +++ b/drivers/base/property.c
>>> @@ -14,6 +14,7 @@
>>>    #include <linux/export.h>
>>>    #include <linux/kernel.h>
>>>    #include <linux/of.h>
>>> +#include <linux/of_address.h>
>>>    #include <linux/property.h>
>>>
>>>    /**
>>> @@ -519,3 +520,14 @@ unsigned int device_get_child_node_count(struct device *dev)
>>>    	return count;
>>>    }
>>>    EXPORT_SYMBOL_GPL(device_get_child_node_count);
>>> +
>>> +bool device_dma_is_coherent(struct device *dev)
>>> +{
>>> +	if (IS_ENABLED(CONFIG_OF) && dev->of_node)
>>
>> Do you really need that IS_ENABLED(CONFIG_OF) ?
>> In other words, dev->of_node should be null for !CONFIG_OF
>
> Yes, but IS_ENABLED(CONFIG_OF) causes the check to be optimized away by the
> compiler if CONFIG_OF is not enabled.
>
Sure but my point was why you need it when just 'dev->of_node' check
is enough. May be I missed something.

Regards,
Santosh
