From: Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at>
Subject: Re: IPSEC in 2.6.25 causes stalled connections
Date: Thu, 10 Jul 2008 15:16:42 +0200
Message-ID: <20080710131642.GB22105@swan.nt.tuwien.ac.at>
References: <20080608010858.GA8877@swan.nt.tuwien.ac.at> <E1K8TuP-0002Qd-00@gondolin.me.apana.org.au> <20080618004544.GA25439@swan.nt.tuwien.ac.at> <20080708080742.GA25027@gondor.apana.org.au> <20080708213302.GA28842@swan.nt.tuwien.ac.at> <20080709084334.GA12484@gondor.apana.org.au> <20080710094345.GA24162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swan.nt.tuwien.ac.at ([128.131.67.158]:46939 "EHLO
	swan.nt.tuwien.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbYGJNQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 09:16:45 -0400
Content-Disposition: inline
In-Reply-To: <20080710094345.GA24162@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 05:43:45PM +0800, Herbert Xu wrote:
> 
> OK, found it: chainiv never called the completion function!
> 
> commit 066068afee313b7746e7a3de05b57dcd4149a2fe
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Jul 10 17:42:36 2008 +0800
> 
>     crypto: chainiv - Invoke completion function
>     
>     When chainiv postpones requests it never calls their completion functions.
>     This causes symptoms such as memory leaks when IPsec is in use.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Confirmed, your patch fixes the problem.

Thanks a lot!

Thomas
