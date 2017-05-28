From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 02/12] nfp: set driver VF limit
Date: Sun, 28 May 2017 14:16:53 -0700
Message-ID: <20170528141653.070fe118@cakuba.lan>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
        <20170528003411.17603-3-jakub.kicinski@netronome.com>
        <BLUPR0701MB200496130E22B9820F7C1D858DF20@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:5261 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750802AbdE1VRA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 17:17:00 -0400
In-Reply-To: <BLUPR0701MB200496130E22B9820F7C1D858DF20@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 May 2017 14:49:58 +0000, Mintz, Yuval wrote:
> >  	pf->limit_vfs = nfp_rtsym_read_le(pf->cpp, "nfd_vf_cfg_max_vfs",
> > &err);
> >  	if (!err)
> > -		return;
> > +		return pci_sriov_set_totalvfs(pf->pdev, pf->limit_vfs);  
> 
> While you're at it, If you're going to enforce the limit at the PCI level,
> shouldn't you retire 'limit_vfs' altogether?

I don't think so, unfortunately.  Sometimes FW sets this value to 0,
which means no VFs should be used, but the PCIe subsystem uses 0 as
"driver limit not set" :(

I will put that in the commit message.
 
> BTW, under which conditions would you expect to find a difference
> in the maximal number of VFs?

It mostly comes down to how FW projects choose to partition PCIe-side
resources on the NFP.  Some project for which SR-IOV is not a priority
may want to disable it completely.  The NFP is very software-driven,
including most of PCIe interactions, descriptor formats etc.  It's
really up to particular projects to shape how the card works.
