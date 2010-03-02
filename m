From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Tue, 2 Mar 2010 17:59:46 +0100
Message-ID: <20100302165946.GC6491@dhcp-lab-161.englab.brq.redhat.com>
References: <20100302135555.GC2362@dhcp-lab-161.englab.brq.redhat.com> <C27F8246C663564A84BB7AB34397724218312F8FD4@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Matthew Carlson <mcarlson@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab0CBRBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 12:01:40 -0500
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB34397724218312F8FD4@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 08:18:44AM -0800, Michael Chan wrote:
> Stanislaw Gruszka wrote:
> 
> > On Tue, Mar 02, 2010 at 04:50:59AM -0800, Vladislav Zolotarov wrote:
> > > Stanislaw barrier() is not a memory barrier - it's a
> > compiler barrier. I don't think removing it from
> > bnx2x_tx_avail() will improve anything. If u think I'm wrong,
> > could u, pls., provide a specific example.
> >
> > Only improvement is removing confusing code, And comment like
> > "Tell compiler that prod and cons can change" is even more
> > confusing. If you think I'm wrong, just tell as why that
> > barrier is needed :)
> 
> The barrier (compiler barrier at least) is required in
> bnx2x_tx_avail().  The status block index can be updated by DMA and
> the compiler doesn't know it (because it is considered wrong to

If you are telling status block index you mean which variable ?
 
> declare the status block as volatile).  Near the end of
> bnx2x_start_xmit() where we call bnx2x_tx_avail() twice.  It is
> possible that the compiler will optimize it and not look at the
> status block in memory the second time.

Ok, I'm trying to understand.
