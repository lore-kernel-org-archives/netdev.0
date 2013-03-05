From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 1/8] netback: don't bind kthread to cpu
Date: Tue, 5 Mar 2013 13:30:10 +0000
Message-ID: <1362490210.4748.23.camel@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	 <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
	 <20130304205154.GB16762@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:19863 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756385Ab3CENaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 08:30:21 -0500
In-Reply-To: <20130304205154.GB16762@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 20:51 +0000, Konrad Rzeszutek Wilk wrote:
> On Fri, Feb 15, 2013 at 04:00:02PM +0000, Wei Liu wrote:
> > The initialization process makes an assumption that the online cpus are
> > numbered from 0 to xen_netbk_group_nr-1,  which is not always true.
> 
> And xen_netbk_group_nr is num_online_cpus()?
> 

Yes.

> So under what conditions does this change? Is this when the CPU hotplug
> is involved and the CPUs go offline? In which case should there be a

Yes, the hotplug path.

> CPU hotplug notifier to re-bind the workers are appropiate?
> 
> > 
> > As we only need a pool of worker threads, simply don't bind them to specific
> > cpus.
> 
> OK. Is there another method of doing this? Are there patches to make the thread
> try to be vCPU->guest affinite?
> 

No, not at the moment.


Wei.
