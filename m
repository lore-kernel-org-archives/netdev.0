From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Fri, 29 Jul 2011 00:04:27 +0200
Message-ID: <1311890667.2677.22.camel@deadeye>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	 <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
	 <1311888004.2677.18.camel@deadeye>
	 <43F901BD926A4E43B106BF17856F0755019414D910@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13272 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab1G1WEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 18:04:31 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019414D910@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-28 at 14:34 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Ben Hutchings
> > Sent: Thursday, July 28, 2011 2:20 PM
> > To: Rose, Gregory V
> > Cc: netdev@vger.kernel.org; davem@davemloft.net; Kirsher, Jeffrey T
> > Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> > 
> > On Wed, 2011-07-27 at 15:17 -0700, Greg Rose wrote:
> > > Add new set commands to configure the number of SR-IOV VFs, the
> > > number of VM queues and spoof checking on/off switch.
> > >
> > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > ---
> > >
> > >  include/linux/ethtool.h |   11 ++++++++++-
> > >  1 files changed, 10 insertions(+), 1 deletions(-)
> > >
> > > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > > index c6e427a..c4972ba 100644
> > > --- a/include/linux/ethtool.h
> > > +++ b/include/linux/ethtool.h
> > > @@ -36,12 +36,14 @@ struct ethtool_cmd {
> > >  	__u8	mdio_support;
> > >  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
> > >  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> > > +	__u32	num_vfs;	/* Enable SR-IOV VFs */
> > 
> > What are the semantics of changing this after VFs have already been set
> > up?
> 
> There's an example of it patch 4/4 in this set.  The PF driver checks
> if any VFs are assigned and active and if not then it will disable and
> destroy all the current VFs via a call to pci_disable_sriov() and then
> call pci_enable_sriov() with the new number of VFs.  Or, if the number
> of new VFs is zero then SR-IOV is left disabled on that PF.

And otherwise the request fails?

> Mostly this is to accommodate customer requests to be able to set a
> different number of VFs per PF or to only have specified PFs enable
> VFs.  The current usage of the max_vfs module parameter is unwieldy in
> this sense as you must enable SR-IOV VFs on all physical functions
> found during the device probe with the same number of VFs.

Right, this makes a lot of sense.

> > > +	__u32	num_vmqs;	/* Set number of queues for VMDq */
> > 
> > VMDq is an Intel proprietary name.  Please specify this in generic
> > terms.
> 
> I'll use the more generic term VM queues.
[...]

Still ambiguous.  I think what you actually intend is that this will be
the number of RX queues and the number of TX queues per VF.  Right?
You might want to allow for different numbers of RX and TX queues.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

