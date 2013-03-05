From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/8] netback: don't bind kthread to cpu
Date: Tue, 5 Mar 2013 10:52:41 -0500
Message-ID: <20130305155241.GB15431@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
 <20130304205154.GB16762@phenom.dumpdata.com>
 <1362490210.4748.23.camel@zion.uk.xensource.com>
 <20130305135649.GA2589@phenom.dumpdata.com>
 <51360452.5070200@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50992 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab3CEPwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 10:52:49 -0500
Content-Disposition: inline
In-Reply-To: <51360452.5070200@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 05, 2013 at 02:42:26PM +0000, David Vrabel wrote:
> On 05/03/13 13:56, Konrad Rzeszutek Wilk wrote:
> > On Tue, Mar 05, 2013 at 01:30:10PM +0000, Wei Liu wrote:
> >> On Mon, 2013-03-04 at 20:51 +0000, Konrad Rzeszutek Wilk wrote:
> >>> On Fri, Feb 15, 2013 at 04:00:02PM +0000, Wei Liu wrote:
> >>>> The initialization process makes an assumption that the online cpus are
> >>>> numbered from 0 to xen_netbk_group_nr-1,  which is not always true.
> >>>
> >>> And xen_netbk_group_nr is num_online_cpus()?
> >>>
> >>
> >> Yes.
> >>
> >>> So under what conditions does this change? Is this when the CPU hotplug
> >>> is involved and the CPUs go offline? In which case should there be a
> >>
> >> Yes, the hotplug path.
> >>
> >>> CPU hotplug notifier to re-bind the workers are appropiate?
> > 
> > ?
> > Can't that option be explored?
> 
> I'm not sure binding netback threads to particular VCPUs is useful
> without also binding the events to the corresponding VCPUs.
> 
> I would hope that the scheduler would tend to the correct behavior if
> threads aren't bound, anyway.

That is fine too. If that is what we want we just need to make the git
commit message be more descriptive of why we don't want to bind
to VCPUs.
> 
> David
