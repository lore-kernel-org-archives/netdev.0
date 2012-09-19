From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New commands to configure IOV features
Date: Wed, 19 Sep 2012 20:44:07 +0100
Message-ID: <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com>
References: <5003DC9B.8000706@broadcom.com> <5005BD00.4090106@redhat.com>
	 <5005D45D.1040302@genband.com>
	 <20120717.141153.46613285253481776.davem@davemloft.net>
	 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009B186.6000806@genband.com>
	 <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com>
	 <500D6932.8090306@genband.com>
	 <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
	 <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
	 <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20120919085306.00006af9@unknown>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 08:53 -0700, Greg Rose wrote:
> On Wed, 19 Sep 2012 14:07:19 +0300
> Yuval Mintz <yuvalmin@broadcom.com> wrote:
[...]
> > We've encountered a problem though - all drivers currently supporting
> > SRIOV do so with the usage of a module param: e.g., 'max_vfs' for
> > ixgbe, 'num_vfs' for benet, etc.
> > The SRIOV feature is disabled by default on all the drivers; it can
> > only be enabled via usage of the module param.
> > 
> > We don't want the lack of SRIOV module param in the bnx2x driver to be
> > the bottle-neck when we'll submit the SRIOV feature upstream, and we
> > also don't want to enable SRIOV by default (following the same logic
> > of other drivers; most users don't use SRIOV and it would strain their
> > resources).
> > 
> > As we see it, there are several possible ways of solving the issue:
> >  1. Use some network-tool (e.g., ethtool).
> >  2. Implement a standard sysfs interface for PCIe devices, as SRIOV is
> >     not solely network-related (this should be done via the PCI linux
> >     tree).

There is another interim option, which is to put this setting somewhere
in NVRAM on the device.  This solves the one-size-for-all-devices
problem, though obviously not the inconsistent-interface problem.

> I was not able to attend the Linux conference held at the end of August
> myself but coworkers of mine here at Intel informed that method 2 here
> seems to be the preferred approach.  Perhaps some folks who attended
> the the conference can chime in with more specifics.

There really wasn't much more specific discussion.  Bjorn's summary of
the mini-summit <http://lwn.net/Articles/514113/> says:

> SR-IOV Management
> 
>     Currently drivers implement module parameters like "max_vfs".  This means
>     all devices claimed by the driver get the same number of VFs, and you can't
>     change anything without unloading and reloading the driver.
> 
>     Consensus that we should try to implement a knob for this in sysfs so it
>     can be generic (not in each driver) and set individually for each device.

I don't think any implementation has been posted to the linux-pci list
yet...?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
