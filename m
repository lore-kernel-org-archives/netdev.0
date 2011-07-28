From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Thu, 28 Jul 2011 08:51:05 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019414D509@orsmsx508.amr.corp.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	<20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
 <20110727.222749.1654973220321763098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16396 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617Ab1G1PvH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 11:51:07 -0400
In-Reply-To: <20110727.222749.1654973220321763098.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 27, 2011 10:28 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; Kirsher, Jeffrey T
> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Wed, 27 Jul 2011 15:17:59 -0700
> 
> > Add new set commands to configure the number of SR-IOV VFs, the
> > number of VM queues and spoof checking on/off switch.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > ---
> >
> >  include/linux/ethtool.h |   11 ++++++++++-
> >  1 files changed, 10 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > index c6e427a..c4972ba 100644
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > @@ -36,12 +36,14 @@ struct ethtool_cmd {
> >  	__u8	mdio_support;
> >  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
> >  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> > +	__u32	num_vfs;	/* Enable SR-IOV VFs */
> > +	__u32	num_vmqs;	/* Set number of queues for VMDq */
> 
> You can't change the layout of this datastructure in this way without
> breaking every ethtool binary out there.
> 
> You have to find another place to add these knobs.

Perhaps at the end of the ethtool_cmd structure?  Something like this:

/* This should work for both 32 and 64 bit userland. */
struct ethtool_cmd {
        __u32   cmd;
        __u32   supported;      /* Features this interface supports */
        __u32   advertising;    /* Features this interface advertises */
        __u16   speed;          /* The forced speed (lower bits) in
                                 * Mbps. Please use
                                 * ethtool_cmd_speed()/_set() to
                                 * access it */
        __u8    duplex;         /* Duplex, half or full */
        __u8    port;           /* Which connector port */
        __u8    phy_address;
        __u8    transceiver;    /* Which transceiver to use */
        __u8    autoneg;        /* Enable or disable autonegotiation */
        __u8    mdio_support;
        __u32   maxtxpkt;       /* Tx pkts before generating tx int */
        __u32   maxrxpkt;       /* Rx pkts before generating rx int */
        __u16   speed_hi;       /* The forced speed (upper
                                 * bits) in Mbps. Please use
                                 * ethtool_cmd_speed()/_set() to
                                 * access it */
        __u8    eth_tp_mdix;
        __u8    spoof_check;    /* Enable/Disable anti-spoofing */
        __u32   lp_advertising; /* Features the link partner advertises */
        __u32   reserved[2];
        __u32   num_vfs;        /* Enable SR-IOV VFs */
        __u32   num_vmqs;       /* Set number of queues for VMDq */
};

- Greg


