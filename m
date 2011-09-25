From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 05/10] if_link: Add additional parameter to
 IFLA_VF_INFO for spoof checking
Date: Sun, 25 Sep 2011 21:06:49 +0100
Message-ID: <1316981213.4122.106.camel@deadeye>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316855863-6091-6-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110925102238.55ba72eb@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28012 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab1IYUHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 16:07:03 -0400
In-Reply-To: <20110925102238.55ba72eb@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-25 at 10:22 -0700, Stephen Hemminger wrote:
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
> to handle the case of tools sending the old ifla_vf_info. Users may have older version
> of ip utilities that send smaller size structure.

Unless I'm missing something, that structure is not sent or received by
userland; that's why I thought it should be #ifdef __KERNEL__.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
