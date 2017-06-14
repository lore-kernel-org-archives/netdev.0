From: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Subject: Re: [PATCH 21/44] powerpc: implement ->mapping_error
Date: Wed, 14 Jun 2017 19:17:27 +1000
Message-ID: <87vanz2ajc.fsf@concordia.ellerman.id.au>
References: <20170608132609.32662-1-hch@lst.de>
	<20170608132609.32662-22-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
	linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alistair Popple  <apopple-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170608132609.32662-22-hch-jcswGhMUV9g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org> writes:

> DMA_ERROR_CODE is going to go away, so don't rely on it.  Instead
> define a ->mapping_error method for all IOMMU based dma operation
> instances.  The direct ops don't ever return an error and don't
> need a ->mapping_error method.
>
> Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
> ---
>  arch/powerpc/include/asm/dma-mapping.h |  4 ----
>  arch/powerpc/include/asm/iommu.h       |  4 ++++
>  arch/powerpc/kernel/dma-iommu.c        |  6 ++++++
>  arch/powerpc/kernel/iommu.c            | 28 ++++++++++++++--------------
>  arch/powerpc/platforms/cell/iommu.c    |  1 +
>  arch/powerpc/platforms/pseries/vio.c   |  3 ++-
>  6 files changed, 27 insertions(+), 19 deletions(-)

I also see:

  arch/powerpc/kernel/dma.c:const struct dma_map_ops dma_direct_ops = {

Which you mentioned can't fail.

  arch/powerpc/platforms/pseries/ibmebus.c:static const struct dma_map_ops ibmebus_dma_ops = {

Which can't fail.

And:

  arch/powerpc/platforms/powernv/npu-dma.c:static const struct dma_map_ops dma_npu_ops = {
  arch/powerpc/platforms/ps3/system-bus.c:static const struct dma_map_ops ps3_sb_dma_ops = {
  arch/powerpc/platforms/ps3/system-bus.c:static const struct dma_map_ops ps3_ioc0_dma_ops = {

All of which look like they definitely can fail, but return 0 on error
and don't implement ->mapping_error.

So I guess I'm acking this and adding a TODO to fix up the NPU code at
least, the ps3 code is probably better left alone these days.

Acked-by: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>

cheers
