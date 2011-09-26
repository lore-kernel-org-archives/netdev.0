From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next 05/10] if_link: Add additional parameter to
 IFLA_VF_INFO for spoof checking
Date: Mon, 26 Sep 2011 09:37:57 -0700
Message-ID: <20110926093757.6a9fa23e@nehalam.linuxnetplumber.net>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1316855863-6091-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110925102238.55ba72eb@s6510.linuxnetplumber.net>
	<1316981213.4122.106.camel@deadeye>
	<20110926091426.5c83a4d7@nehalam.linuxnetplumber.net>
	<43F901BD926A4E43B106BF17856F0755019C5193B4@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58679 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab1IZQiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 12:38:07 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C5193B4@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Sep 2011 09:32:35 -0700
"Rose, Gregory V" <gregory.v.rose@intel.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > Sent: Monday, September 26, 2011 9:14 AM
> > To: Ben Hutchings
> > Cc: Kirsher, Jeffrey T; davem@davemloft.net; Rose, Gregory V;
> > netdev@vger.kernel.org; gospo@redhat.com
> > Subject: Re: [net-next 05/10] if_link: Add additional parameter to
> > IFLA_VF_INFO for spoof checking
> > 
> > On Sun, 25 Sep 2011 21:06:49 +0100
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> > > On Sun, 2011-09-25 at 10:22 -0700, Stephen Hemminger wrote:
> > > > On Sat, 24 Sep 2011 02:17:38 -0700
> > > > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > > >
> > > > > From: Greg Rose <gregory.v.rose@intel.com>
> > > > >
> > > > > Add configuration setting for drivers to turn spoof checking on or
> > off
> > > > > for discrete VFs.
> > > > >
> > > > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > > ---
> > > > >  include/linux/if_link.h   |    7 +++++++
> > > > >  include/linux/netdevice.h |    3 +++
> > > > >  net/core/rtnetlink.c      |   25 ++++++++++++++++++++++---
> > > > >  3 files changed, 32 insertions(+), 3 deletions(-)
> > > > >
> > > > > diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> > > > > index 0ee969a..8bd6d6d 100644
> > > > > --- a/include/linux/if_link.h
> > > > > +++ b/include/linux/if_link.h
> > > > > @@ -279,6 +279,7 @@ enum {
> > > > >  	IFLA_VF_MAC,		/* Hardware queue specific attributes
> > */
> > > > >  	IFLA_VF_VLAN,
> > > > >  	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
> > > > > +	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
> > > > >  	__IFLA_VF_MAX,
> > > > >  };
> > > > >
> > > > > @@ -300,12 +301,18 @@ struct ifla_vf_tx_rate {
> > > > >  	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling
> > */
> > > > >  };
> > > > >
> > > > > +struct ifla_vf_spoofchk {
> > > > > +	__u32 vf;
> > > > > +	__u32 setting;
> > > > > +};
> > > > > +
> > > > >  struct ifla_vf_info {
> > > > >  	__u32 vf;
> > > > >  	__u8 mac[32];
> > > > >  	__u32 vlan;
> > > > >  	__u32 qos;
> > > > >  	__u32 tx_rate;
> > > > > +	__u32 spoofchk;
> > > > >  };
> > > >
> > > > This breaks ABI compatibility, unless you add some special case code
> > > > to handle the case of tools sending the old ifla_vf_info. Users may
> > have older version
> > > > of ip utilities that send smaller size structure.
> > >
> > > Unless I'm missing something, that structure is not sent or received by
> > > userland; that's why I thought it should be #ifdef __KERNEL__.
> > 
> > The struct ifla_vf_info is exposed to userland, it is not inside the
> > #ifdef
> > and therefore exposed.
> > 
> > But it is probably okay to change this structure because the ifla_vf_info
> > is not used/supported by any released version iproute2.  There may have
> > been
> > some patches to use this, but they never made it into the git or released
> > code.
> > 
> 
> I will respin the patches with *ifdef __KERNEL__ wrapper.
> 
> Thanks,
> 
> - Greg
> 

Just make spoofchk a new nested attribute.
