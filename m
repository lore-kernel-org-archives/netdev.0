From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/34]bnx2x: Compilation issue on IA64
Date: Wed, 14 Jan 2009 13:10:58 -0800 (PST)
Message-ID: <20090114.131058.248785392.davem@davemloft.net>
References: <1231951391.11301.131.camel@lb-tlvb-eliezer>
	<1231952824.3010.29.camel@achroite>
	<1231955073.11301.161.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754383AbZANVK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 16:10:57 -0500
In-Reply-To: <1231955073.11301.161.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 19:44:33 +0200

> On Wed, 2009-01-14 at 09:07 -0800, Ben Hutchings wrote:
> > On Wed, 2009-01-14 at 18:43 +0200, Eilon Greenstein wrote:
> > > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> [...]  
> > >  #ifdef BNX2X_STOP_ON_ERROR
> > >  	fp->tpa_queue_used |= (1 << queue);
> > > -#ifdef __powerpc64__
> > > +#if (defined __powerpc64__) || (defined _ASM_IA64_TYPES_H)
> > >  	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
> > >  #else
> > >  	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
> > 
> > Or you could cast the value to unsigned long long and remove this
> > fragile #ifdef.
> > 
> You are right - it is a better solution. The issue is that this uglier
> solution is already in, and I hate to re-send this patch just for this.
> Can we have this one applied and I will re visit it in net-next?

There is no reason to crap up any driver with arch ifdefs, absolutely
none, for this typing issue.

The whole point is that we're trying to get all of the arch's to use
the same type for u64 in the kernel, so that these warnings can be
cleared away very easily.

Live with the warnings meanwhile until this is all sorted out.
