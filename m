From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V5 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Fri, 22 May 2015 17:24:15 -0500
Message-ID: <555FAC8F.4010306@amd.com>
References: <1432159758-4486-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1432159758-4486-2-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1815824.lIg0NQ97lU@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<arnd@arndb.de>, <msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0109.outbound.protection.outlook.com ([157.56.111.109]:58191
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946171AbbEVWY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 18:24:58 -0400
In-Reply-To: <1815824.lIg0NQ97lU@vostro.rjw.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure if this went out earlier. So I am resending.

On 5/22/15 16:56, Rafael J. Wysocki wrote:
>> diff --git a/drivers/acpi/glue.c b/drivers/acpi/glue.c
>> >index 39c485b..b9657af 100644
>> >--- a/drivers/acpi/glue.c
>> >+++ b/drivers/acpi/glue.c
>> >@@ -13,6 +13,7 @@
>> >  #include <linux/slab.h>
>> >  #include <linux/rwsem.h>
>> >  #include <linux/acpi.h>
>> >+#include <linux/dma-mapping.h>
>> >
>> >  #include "internal.h"
>> >
>> >@@ -167,6 +168,7 @@ int acpi_bind_one(struct device *dev, struct acpi_device *acpi_dev)
>> >  	struct list_head *physnode_list;
>> >  	unsigned int node_id;
>> >  	int retval = -EINVAL;
>> >+	bool coherent;
>> >
>> >  	if (has_acpi_companion(dev)) {
>> >  		if (acpi_dev) {
>> >@@ -223,6 +225,9 @@ int acpi_bind_one(struct device *dev, struct acpi_device *acpi_dev)
>> >  	if (!has_acpi_companion(dev))
>> >  		ACPI_COMPANION_SET(dev, acpi_dev);
>> >
>> >+	if (acpi_check_dma(acpi_dev, &coherent))
>> >+		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);
>> >+
> Well, so is this going to work for PCI too after all?
>

No, as Bjorn suggested, PCI changes for setting DMA coherent from _CCA 
(patch 3/6 in V4) will be submitted separately. We are working on 
cleaning up and up-streaming the PCI ACPI support for ARM64.

Thanks,

Suravee
