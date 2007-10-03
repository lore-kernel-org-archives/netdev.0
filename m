From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Fix rose.ko oops on unload
Date: Wed, 3 Oct 2007 23:21:33 +0400
Message-ID: <20071003192133.GB16242@martell.zuzino.mipt.ru>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru> <4703E7B4.2090309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	pidoux@ccr.jussieu.fr
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:63991 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbXJCTWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 15:22:24 -0400
Received: by nf-out-0910.google.com with SMTP id g13so3900796nfb
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 12:22:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4703E7B4.2090309@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 03, 2007 at 03:04:20PM -0400, Jeff Garzik wrote:
> Alexey Dobriyan wrote:
> >Quick'n'dirty fix to 100% oops on "rmmod rose". Do you want me to
> >properly unwind everything before .24?
> >-----------
> >Commit a3d384029aa304f8f3f5355d35f0ae274454f7cd aka
> >"[AX.25]: Fix unchecked rose_add_loopback_neigh uses"
> >transformed rose_loopback_neigh var into statically allocated one.
> >However, on unload it will be kfree's which can't work.
> 
> I'm definitely missing something...  assuming your patch is applied, 
> where is the kfree() for rose_loopback_neigh ?

AFAICS, it will be glued to rose_neigh_list in rose_add_loopback_neigh().
On unload, found and rose_remove_neigh() will free it.
