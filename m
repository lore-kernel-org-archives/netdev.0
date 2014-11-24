From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net_tx_action race condition?
Date: Mon, 24 Nov 2014 23:08:32 +0800
Message-ID: <20141124150832.GA32184@gondor.apana.org.au>
References: <547332D7.7050104@3dautomazione.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Angelo Rizzi <angelo.rizzi@3dautomazione.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41068 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbaKXPIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 10:08:36 -0500
Content-Disposition: inline
In-Reply-To: <547332D7.7050104@3dautomazione.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Angelo Rizzi <angelo.rizzi@3dautomazione.it> wrote:
> [-- text/plain, encoding 7bit, charset: iso-8859-15, 22 lines --]
> 
> Hi Daniel,
> Here attached the patch file you required.
> The problem i've found is on the declaration of 'struct softnet_data 
> *sd' in function 'net_tx_action'
> What happens to me (i have an embedded system based on FPGA and a NIOS2 
> cpu) is that, due to compiler optimization, the content of 
> 'sd->completion_queue' is saved in a CPU register before interrupt 
> disabling (when the instruction 'if (sd->completion_queue) {' is 
> executed) and then the register contents is used for interrupt-disabled 
> assignment ('clist = sd->completion_queue') instead of re-read the 
> variable contents.
> This seems to lead to a race condition when an interrupt modifies the 
> content of 'sd->completion_queue' between these two instructions.
> What i have done to avoid this situation is to change the declaration of 
> 'struct softnet_data *sd' to 'volatile struct softnet_data *sd' and now 
> everything seems to be ok.
> I hope this will help.

local_irq_disable is supposed to contain a compiler barrier.  So
this is either a buggy arch or a buggy compiler.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
