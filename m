From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 11 Mar 2010 14:10:28 +0100
Message-ID: <20100311131027.GA5040@dhcp-lab-161.englab.brq.redhat.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com> <31355.1268240990@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932238Ab0CKNMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 08:12:19 -0500
Content-Disposition: inline
In-Reply-To: <31355.1268240990@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 05:09:50PM +0000, David Howells wrote:
> Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> 
> > -	barrier(); /* Tell compiler that prod and cons can change */
> > +	/* prod and cons can change on other cpu, want to see
> > +	   consistend available space and queue (stop/running) state */
> > +	smp_mb();
> > +
> >  	prod = fp->tx_bd_prod;
> >  	cons = fp->tx_bd_cons;
> 
> I suspect that this isn't what you want.

Yes, I realized that. I posted other patches, removing you from CC, since
thought you are not interested.

http://patchwork.ozlabs.org/patch/47172/
http://patchwork.ozlabs.org/patch/47173/
http://patchwork.ozlabs.org/patch/47174/

I removed there barrier() and not use smp_mb(), with explanation why.

Stanislaw
