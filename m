From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/8] i40e: main driver core
Date: Thu, 20 Jun 2013 20:54:45 +0100
Message-ID: <1371758085.1946.12.camel@bwh-desktop.uk.level5networks.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371665562.1956.89.camel@bwh-desktop.uk.level5networks.com>
	 <FC41C24E35F18A40888AACA1A36F3E4168533EA6@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40689 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965319Ab3FTTyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 15:54:50 -0400
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E4168533EA6@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 19:46 +0000, Nelson, Shannon wrote:
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Wednesday, June 19, 2013 11:13 AM
> > 
> > On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
> > > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
[...]
> > > +/**
> > > + * i40e_get_vsi_stats_struct - Get System Network Statistics
> > > + * @vsi: the VSI we care about
> > > + *
> > > + * Returns the address of the device statistics structure.
> > > + * The statistics are actually updated from the service task.
> > > + **/
> > > +struct net_device_stats *i40e_get_vsi_stats_struct(struct i40e_vsi
> > *vsi)
> > > +{
> > > +	/* only return the current stats */
> > > +	/* It is possible for a VSIs to not have a netdev */
> > > +	if (vsi->netdev)
> > > +		return &vsi->netdev->stats;
> > > +	else
> > > +		return &vsi->net_stats;
> > > +}
> > 
> > You should be using rtnl_device_stats64; at 40G a 32-bit counter is
> > ridiculous (using this in a 32-bit machine is a bit ridiculous too,
> > though...)
> 
> You mean rtnl_link_stats64?  Sure.

Right, yes.

> Yes, this driver is really not meant for a 32-bit machine.  We've
> discussed making sure it would only build for 64-bit, but hadn't quite
> gotten around to implementing the restriction.  It seems the right
> thing to do - would anyone in the community get bent out of shape if
> we added that?

I'm afraid they probably would.

[...]
> > > +/**
> > > + * i40e_config_rss - Prepare for RSS if used
> > > + * @pf: board private structure
> > > + **/
> > > +static s32 i40e_config_rss(struct i40e_pf *pf)
> > > +{
> > > +	struct i40e_hw *hw = &pf->hw;
> > > +	u32 lut = 0;
> > > +	int i, j;
> > > +	u64 hena;
> > > +	/* Set of random keys generated using kernel random number
> > generator */
> > > +	static const u32 seed[I40E_PFQF_HKEY_MAX_INDEX + 1] = {0x41b01687,
> > > +				0x183cfd8c, 0xce880440, 0x580cbc3c, 0x35897377,
> > > +				0x328b25e1, 0x4fa98922, 0xb7d90c14, 0xd5bad70d,
> > > +				0xcd15a2c1, 0xe8580225, 0x4a1e9d11, 0xfe5731be};
> > 
> > Chosen by a fair dice roll?
> 
> Well, as fair as /dev/random gets.
[...]

My point is: once you turn a random choice into a constant, it's no
longer random.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
