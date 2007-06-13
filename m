From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 17:53:10 +0200
Message-ID: <18032.4838.904566.652746@robur.slu.se>
References: <466DEF9D.9070509@trash.net>
	<1181615384.4071.121.camel@localhost>
	<466E9DF2.9010505@trash.net>
	<20070612.140240.00078635.davem@davemloft.net>
	<466F0D74.5030308@trash.net>
	<1181714168.4758.57.camel@debian.sh.intel.com>
	<1181737935.4050.87.camel@localhost>
	<18031.60741.695897.572432@robur.slu.se>
	<1181741602.4050.116.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Zhu Yi <yi.zhu@intel.com>,
	Leonid Grossman <Leonid.Grossman@neterion.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:51119 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758365AbXFMQXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 12:23:17 -0400
In-Reply-To: <1181741602.4050.116.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:

 > I think the one described by Leonid has not just 8 tx/rx rings but also
 > a separate register set, MSI binding etc iirc. The only shared resources
 > as far as i understood Leonid are the bus and the ethernet wire.
 
 AFAIK most new NIC will look like this...  

 I still lack a lot of crucial hardware understanding
 
 What will happen when if we for some reason is not capable of serving
 one TX ring? NIC still working so we continue filling/sending/clearing 
 on other rings?

 > So in such a case (assuming 8 rings), 
 > One model is creating 4 netdev devices each based on single tx/rx ring
 > and register set and then having a mother netdev (what you call the
 > bond) that feeds these children netdev based on some qos parametrization
 > is very sensible. Each of the children netdevices (by virtue of how we
 > do things today) could be tied to a CPU for effectiveness (because our
 > per CPU work is based on netdevs).

 Some kind of supervising function for the TX is probably needed as we still 
 want see the device as one entity. But if upcoming HW supports parallelism  
 straight to the TX-ring we of course like to use to get mininal cache 
 effects. It's up to how this "master netdev" or queue superviser can be 
 designed.
  
 > For the Leonid-NIC (for lack of better name) it may be harder to do
 > parallelization on rcv if you use what i said above. But you could
 > use a different model on receive - such as create a single netdev and
 > with 8 rcv rings and MSI tied on rcv to 8 different CPUs 

 Yes that should be the way do it... and ethtool or something to hint 
 the NIC how the incoming data classified wrt available CPU's. Maybe
 something more dynamic for the brave ones.

 Cheers
					-ro
