From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Thu, 28 Jul 2011 09:21:47 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019414D568@orsmsx508.amr.corp.intel.com>
References: <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
	<20110727.222749.1654973220321763098.davem@davemloft.net>
	<43F901BD926A4E43B106BF17856F0755019414D509@orsmsx508.amr.corp.intel.com>
 <20110728.091448.548423057039764289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46062 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755549Ab1G1QVt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 12:21:49 -0400
In-Reply-To: <20110728.091448.548423057039764289.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, July 28, 2011 9:15 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; Kirsher, Jeffrey T
> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Thu, 28 Jul 2011 08:51:05 -0700
> 
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Wednesday, July 27, 2011 10:28 PM
> >> To: Rose, Gregory V
> >> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; Kirsher, Jeffrey
> T
> >> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> >>
> >> From: Greg Rose <gregory.v.rose@intel.com>
> >> Date: Wed, 27 Jul 2011 15:17:59 -0700
> >>
> >> > Add new set commands to configure the number of SR-IOV VFs, the
> >> > number of VM queues and spoof checking on/off switch.
> >> >
> >> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> >> > ---
> >> >
> >> >  include/linux/ethtool.h |   11 ++++++++++-
> >> >  1 files changed, 10 insertions(+), 1 deletions(-)
> >> >
> >> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> >> > index c6e427a..c4972ba 100644
> >> > --- a/include/linux/ethtool.h
> >> > +++ b/include/linux/ethtool.h
> >> > @@ -36,12 +36,14 @@ struct ethtool_cmd {
> >> >  	__u8	mdio_support;
> >> >  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
> >> >  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> >> > +	__u32	num_vfs;	/* Enable SR-IOV VFs */
> >> > +	__u32	num_vmqs;	/* Set number of queues for VMDq */
> >>
> >> You can't change the layout of this datastructure in this way without
> >> breaking every ethtool binary out there.
> >>
> >> You have to find another place to add these knobs.
> >
> > Perhaps at the end of the ethtool_cmd structure?  Something like this:
> 
> Either use the two reserved u32's we have there, or create a new
> ethtool command and control structure.

OK, I see what you're saying.  The size of the structure can never be changed.  I'm slow sometimes but I do eventually get there.  I didn't want to use the reserved u32's because I didn't know what they were reserved for.  The num_vfs and num_vmqs values will actually never exceed 8 bits.  I'll stuff them into the space used by one of the u32's and then add padding to align and keep the same structure size.

Thanks for the feedback and help.  I'll address this and the other feedback I've gotten and come back later with V2 of the RFC.

- Greg


