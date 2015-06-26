From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net] bnx2x: fix DMA API usage
Date: Fri, 26 Jun 2015 17:57:05 +0200
Message-ID: <558D7651.7020909@redhat.com>
References: <1435333800-22447-1-git-send-email-mschmidt@redhat.com> <1435333800-22447-2-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbbFZP5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 11:57:08 -0400
In-Reply-To: <1435333800-22447-2-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2015 05:50 PM, Michal Schmidt wrote:
> With CONFIG_DMA_API_DEBUG=y bnx2x triggers the error "DMA-API: device
> driver frees DMA memory with wrong function".
> On archs where PAGE_SIZE > SGE_PAGE_SIZE it also triggers "DMA-API:
> device driver frees DMA memory with different size".
> 
> Fix this by making the mapping and unmapping symmetric:
>  - Do not map the whole pool page at once. Instead map the
>    SGE_PAGE_SIZE-sized pieces individually, so they can be unmapped in
>    the same manner.
>  - What's mapped using dma_map_page() must be unmapped using
>    dma_unmap_page().
> 
> Tested on ppc64.
> 
> Fixes: 4cace675d687 ("bnx2x: Alloc 4k fragment for each rx ring buffer element")
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |  1 -
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 23 ++++++++++-------------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 12 ++----------
>  3 files changed, 12 insertions(+), 24 deletions(-)

The two patches I sent are absolutely identical.
I just sent it twice by mistake. Sorry for any confusion.
Michal
