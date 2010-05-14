From: "\"Brandeburg, Jesse\"" <jesse.brandeburg@intel.com>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Fri, 14 May 2010 10:20:41 -0700
Message-ID: <1273857641.3057.20.camel@localhost.localdomain>
References: <20100514134544.GA26674@gretchen.aei.mpg.de>
	 <DDC57477F5D6F845A0DDCB99D3C4812D0CA63BB9E4@orsmsx510.amr.corp.intel.com>
	 <4BED79EB.1000204@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	e1000-devel@lists.sourceforge.net
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9192 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758076Ab0ENRU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 13:20:29 -0400
In-Reply-To: <4BED79EB.1000204@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-05-14 at 09:27 -0700, Tejun Heo wrote:
> Hello, John.
> 
> As Henning seems offline, I'll try to fill in.
> 
> On 05/14/2010 04:51 PM, Ronciak, John wrote:
> > Sorry to hear about the problem you are having Henning.  What do you
> > mean when you say "it disappears"?
> 
> It stops responding to IPMI requests.

We've actually had quite a few problems like this over the years, so I'm
not quite so surprised to hear about something like this.

Its easy to break the reception of IPMI packets because there are a
couple of registers that if not correctly configured during all points
of driver lifetime (probe only, administratively down, up)


> > Can both eth0 and eth1 ping (or be pinged)?  Do all the networking
> > devices still show up in the system when you do an 'lspci'?
> 
> Yeah, everything other than IPMI works just fine.
> 
> > What happens if you down and then up the interface you are having
> > problems with?  Does 'rmmod' do the same thing as your removal
> > method?
> 
> Haven't tried these but well I think rmmoding should achieve about the
> same thing.
> 
> > Is there anything in the system logs saying anything about the
> > interfaces?
> 
> Nope.

One thing that would really help us is to see the stats from ethtool -S
ethX when interface is up, and not receiving IPMI
 
The other "smoking gun" indicator is the output of the register dump
tool called ethregs that we have posted at sourceforge.  Please gather
registers for the card in question before and after loading netconsole.

http://prdownloads.sf.net/e1000/ethregs-1.7.2.tar.gz

> > We have not had reports of this so this is a bit unusual.  Please let us know.
> > 
> > Does this happen on other systems as well or just one particular system?
> 
> Yeah, it happens on at least several hundred machines, so not an
> isolated hardware issue at all.
> 
> To sum up.
> 
> On 2.6.27.39, netconsole + IPMI works fine.  On 2.6.32.7, as soon as
> netconsole is loaded, IPMI stops working.  Unloading netconsole
> doesn't revive IPMI but detaching the driver from the controller does.
> In both cases, usual networking works fine.

I think that "loading netconsole" means bringing the interface "UP", in
this case, is this correct?  To ask another way: Is network traffic
active on the interface in question before netconsole is loaded?

Jesse

