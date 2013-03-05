From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/8] netback: don't bind kthread to cpu
Date: Tue, 5 Mar 2013 08:56:49 -0500
Message-ID: <20130305135649.GA2589@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
 <20130304205154.GB16762@phenom.dumpdata.com>
 <1362490210.4748.23.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49273 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843Ab3CEN46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 08:56:58 -0500
Content-Disposition: inline
In-Reply-To: <1362490210.4748.23.camel@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 05, 2013 at 01:30:10PM +0000, Wei Liu wrote:
> On Mon, 2013-03-04 at 20:51 +0000, Konrad Rzeszutek Wilk wrote:
> > On Fri, Feb 15, 2013 at 04:00:02PM +0000, Wei Liu wrote:
> > > The initialization process makes an assumption that the online cpus are
> > > numbered from 0 to xen_netbk_group_nr-1,  which is not always true.
> > 
> > And xen_netbk_group_nr is num_online_cpus()?
> > 
> 
> Yes.
> 
> > So under what conditions does this change? Is this when the CPU hotplug
> > is involved and the CPUs go offline? In which case should there be a
> 
> Yes, the hotplug path.
> 
> > CPU hotplug notifier to re-bind the workers are appropiate?

?
Can't that option be explored?
> > 
> > > 
> > > As we only need a pool of worker threads, simply don't bind them to specific
> > > cpus.
> > 
> > OK. Is there another method of doing this? Are there patches to make the thread
> > try to be vCPU->guest affinite?
> > 
> 
> No, not at the moment.
> 
> 
> Wei.
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
