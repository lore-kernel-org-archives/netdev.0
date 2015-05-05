From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V2 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Tue, 5 May 2015 11:09:38 -0500
Message-ID: <5548EB42.5010800@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1430838729-21572-3-git-send-email-Suravee.Suthikulpanit@amd.com>
 <5126612.k0u2CL2zi5@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, herbert@gondor.apana.org.au, al.stone@linaro.org,
 linaro-acpi@lists.linaro.org, catalin.marinas@arm.com, msalter@redhat.com,
 rjw@rjwysocki.net, linux-kernel@vger.kernel.org, will.deacon@arm.com,
 linux-crypto@vger.kernel.org, linux-acpi@vger.kernel.org, leo.duran@amd.com,
 hanjun.guo@linaro.org, netdev@vger.kernel.org, grant.likely@linaro.org,
 davem@davemloft.net, lenb@kernel.org
To: Arnd Bergmann <arnd@arndb.de>, <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5126612.k0u2CL2zi5@wuerfel>
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

On 5/5/2015 10:44 AM, Arnd Bergmann wrote:
> On Tuesday 05 May 2015 10:12:06 Suravee Suthikulpanit wrote:
>> +struct dma_map_ops dummy_dma_ops = {
>> +       .alloc                  = __dummy_alloc,
>> +       .free                   = __dummy_free,
>> +       .mmap                   = __dummy_mmap,
>> +       .map_page               = __dummy_map_page,
>> +       .unmap_page             = __dummy_unmap_page,
>> +       .map_sg                 = __dummy_map_sg,
>> +       .unmap_sg               = __dummy_unmap_sg,
>> +       .sync_single_for_cpu    = __dummy_sync_single_for_cpu,
>> +       .sync_single_for_device = __dummy_sync_single_for_device,
>> +       .sync_sg_for_cpu        = __dummy_sync_sg_for_cpu,
>> +       .sync_sg_for_device     = __dummy_sync_sg_for_device,
>> +       .mapping_error          = __dummy_mapping_error,
>> +       .dma_supported          = __dummy_dma_supported,
>> +};
>> +EXPORT_SYMBOL(dummy_dma_ops);
>> +
>>
>
> This will clearly work, but I think it's easier to just leave
> the dma_mask pointer as NULL when creating the platform device,
> which should let the normal dma ops fail all the callbacks.
>
> 	Arnd
>

However, codes in several places are making use of dma_map_ops without 
checking if the ops are NULL (i.e. 
include/asm-generic/dma-mapping-common.h and in arch-specific 
implementation). If setting it to NULL is what we are planning to 
support, we would need to scrub the current code to put NULL check. 
Also, would you consider if that is safe to do going forward?

Thanks,
Suravee
