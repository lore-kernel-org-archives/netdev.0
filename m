From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Tue, 2 Mar 2010 09:26:27 -0800
Message-ID: <1267550787.19491.109.camel@nseg_linux_HP1.broadcom.com>
References: <20100302135555.GC2362@dhcp-lab-161.englab.brq.redhat.com>
 <C27F8246C663564A84BB7AB34397724218312F8FD4@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20100302165946.GC6491@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4084 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952Ab0CBRit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 12:38:49 -0500
In-Reply-To: <20100302165946.GC6491@dhcp-lab-161.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2010-03-02 at 08:59 -0800, Stanislaw Gruszka wrote:
> On Tue, Mar 02, 2010 at 08:18:44AM -0800, Michael Chan wrote:
> > Stanislaw Gruszka wrote:
> > 
> > > On Tue, Mar 02, 2010 at 04:50:59AM -0800, Vladislav Zolotarov wrote:
> > > > Stanislaw barrier() is not a memory barrier - it's a
> > > compiler barrier. I don't think removing it from
> > > bnx2x_tx_avail() will improve anything. If u think I'm wrong,
> > > could u, pls., provide a specific example.
> > >
> > > Only improvement is removing confusing code, And comment like
> > > "Tell compiler that prod and cons can change" is even more
> > > confusing. If you think I'm wrong, just tell as why that
> > > barrier is needed :)
> > 
> > The barrier (compiler barrier at least) is required in
> > bnx2x_tx_avail().  The status block index can be updated by DMA and
> > the compiler doesn't know it (because it is considered wrong to
> 
> If you are telling status block index you mean which variable ?

The fp-> fields which can be updated by NAPI poll based on new status
block DMA.

>  
> > declare the status block as volatile).  Near the end of
> > bnx2x_start_xmit() where we call bnx2x_tx_avail() twice.  It is
> > possible that the compiler will optimize it and not look at the
> > status block in memory the second time.
> 
> Ok, I'm trying to understand.
> --



