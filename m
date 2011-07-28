From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Thu, 28 Jul 2011 23:14:45 +0200
Message-ID: <1311887685.2677.12.camel@deadeye>
References: <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
	 <20110727.222749.1654973220321763098.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755019414D509@orsmsx508.amr.corp.intel.com>
	 <20110728.091448.548423057039764289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7810 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034Ab1G1VOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 17:14:50 -0400
In-Reply-To: <20110728.091448.548423057039764289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-28 at 09:14 -0700, David Miller wrote:
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Thu, 28 Jul 2011 08:51:05 -0700
> 
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Wednesday, July 27, 2011 10:28 PM
> >> To: Rose, Gregory V
> >> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; Kirsher, Jeffrey T
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

I'm going to insist on the latter.  As I see it, struct ethtool_cmd is
for Ethernet PHY settings.  (The max{rx,tx}pkt fields weren't, but
they're obsolete.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

