From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH v4] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Wed, 27 May 2015 10:59:45 +0200
Message-ID: <55658781.8060104@redhat.com>
References: <553AD097.4020209@gmx.de>	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>	<20150430.160537.232956261880122754.davem@davemloft.net>	<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>	<B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org> <87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"LinoSanfilippo@gmx.de" <LinoSanfilippo@gmx.de>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbbE0I7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 04:59:49 -0400
In-Reply-To: <87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/2015 03:20 PM, Gabriel Krisman Bertazi wrote:
> +#define SGE_PAGE_SHIFT		12
> +#define SGE_PAGE_SIZE		(1 << SGE_PAGE_SHIFT)
...
> +struct bnx2x_alloc_pool {
> +	struct page	*page;
> +	dma_addr_t	dma;
> +	u8		offset;
> +	u8		frag_count;
> +};
...
>  static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  			      u16 index, gfp_t gfp_mask)
>  {
        ...
> +	pool->offset += SGE_PAGE_SIZE;
> +	pool->frag_count--;
> +
>  	return 0;
>  }

One SGE_PAGE_SIZE is already bigger than representable by u8, so offset
will overflow.

Isn't storing both 'offset' and 'frag_count' redundant? There is a
simple linear relationship between the two.

Regards,
Michal
