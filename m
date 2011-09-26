From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 05/10] if_link: Add additional parameter to
 IFLA_VF_INFO for spoof checking
Date: Mon, 26 Sep 2011 09:18:34 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C519376@orsmsx508.amr.corp.intel.com>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1316855863-6091-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110925102238.55ba72eb@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59240 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1IZQSg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 12:18:36 -0400
In-Reply-To: <20110925102238.55ba72eb@s6510.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Sunday, September 25, 2011 10:23 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Rose, Gregory V; netdev@vger.kernel.org;
> gospo@redhat.com
> Subject: Re: [net-next 05/10] if_link: Add additional parameter to
> IFLA_VF_INFO for spoof checking
> 
> On Sat, 24 Sep 2011 02:17:38 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > From: Greg Rose <gregory.v.rose@intel.com>
> >
> > Add configuration setting for drivers to turn spoof checking on or off
> > for discrete VFs.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  include/linux/if_link.h   |    7 +++++++
> >  include/linux/netdevice.h |    3 +++
> >  net/core/rtnetlink.c      |   25 ++++++++++++++++++++++---
> >  3 files changed, 32 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> > index 0ee969a..8bd6d6d 100644
> > --- a/include/linux/if_link.h
> > +++ b/include/linux/if_link.h
> > @@ -279,6 +279,7 @@ enum {
> >  	IFLA_VF_MAC,		/* Hardware queue specific attributes */
> >  	IFLA_VF_VLAN,
> >  	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
> > +	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
> >  	__IFLA_VF_MAX,
> >  };
> >
> > @@ -300,12 +301,18 @@ struct ifla_vf_tx_rate {
> >  	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
> >  };
> >
> > +struct ifla_vf_spoofchk {
> > +	__u32 vf;
> > +	__u32 setting;
> > +};
> > +
> >  struct ifla_vf_info {
> >  	__u32 vf;
> >  	__u8 mac[32];
> >  	__u32 vlan;
> >  	__u32 qos;
> >  	__u32 tx_rate;
> > +	__u32 spoofchk;
> >  };
> 
> This breaks ABI compatibility, unless you add some special case code
> to handle the case of tools sending the old ifla_vf_info. Users may have
> older version
> of ip utilities that send smaller size structure.

The structure is not sent directly to the kernel from user space.  The kernel will get the information and stuff it into individual data units using NLA_PUT.  If the older tool doesn't ask for the info then that's fine so far as I can tell.

The only issue I've seen is using the new ip tool on older kernels that don't supply the data.  You'll get a segmentation fault and core dump.  However, I was under the impression that the general rule was to use a release of the ip tool only on the kernel it was released for or on newer kernels.

- Greg
