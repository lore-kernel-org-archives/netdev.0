From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [V2 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Tue, 05 May 2015 17:44:49 +0200
Message-ID: <5126612.k0u2CL2zi5@wuerfel>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1430838729-21572-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, msalter@redhat.com, herbert@gondor.apana.org.au,
 al.stone@linaro.org, rjw@rjwysocki.net, catalin.marinas@arm.com,
 linaro-acpi@lists.linaro.org, will.deacon@arm.com,
 linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-acpi@vger.kernel.org, leo.duran@amd.com, hanjun.guo@linaro.org,
 Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>, netdev@vger.kernel.org,
 grant.likely@linaro.org, davem@davemloft.net, lenb@kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1430838729-21572-3-git-send-email-Suravee.Suthikulpanit@amd.com>
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

On Tuesday 05 May 2015 10:12:06 Suravee Suthikulpanit wrote:
> +struct dma_map_ops dummy_dma_ops = {
> +       .alloc                  = __dummy_alloc,
> +       .free                   = __dummy_free,
> +       .mmap                   = __dummy_mmap,
> +       .map_page               = __dummy_map_page,
> +       .unmap_page             = __dummy_unmap_page,
> +       .map_sg                 = __dummy_map_sg,
> +       .unmap_sg               = __dummy_unmap_sg,
> +       .sync_single_for_cpu    = __dummy_sync_single_for_cpu,
> +       .sync_single_for_device = __dummy_sync_single_for_device,
> +       .sync_sg_for_cpu        = __dummy_sync_sg_for_cpu,
> +       .sync_sg_for_device     = __dummy_sync_sg_for_device,
> +       .mapping_error          = __dummy_mapping_error,
> +       .dma_supported          = __dummy_dma_supported,
> +};
> +EXPORT_SYMBOL(dummy_dma_ops);
> +
> 

This will clearly work, but I think it's easier to just leave
the dma_mask pointer as NULL when creating the platform device,
which should let the normal dma ops fail all the callbacks.

	Arnd
