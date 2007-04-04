From: Patrick McHardy <kaber@trash.net>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 16:07:56 +0200
Message-ID: <4613B13C.3010603@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>	 <4613A9F6.8000307@trash.net> <1175695102.4063.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59859 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850AbXDDOH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:07:58 -0400
In-Reply-To: <1175695102.4063.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-04-04 at 15:36 +0200, Patrick McHardy wrote:
> 
>>It would be interesting to find out what the problem is exactly.
>>The configuration itself looks harmless, so I'm guessing its
>>rather a deadlock than a loop.
> 
> 
> We know it is a deadlock. 
> If you redirect the first time queue lock for eth0 will be held, before
> it is released if you do another redirect, it will again be heading
> towards eth0 and it will deadlock on grabbing the queue lock.


He only used a single redirect to eth0.5, but its probably due to the
fact that the VLAN hard_start_xmit function transmits on eth0 again.
How about adding something like ifb's ri_tasklet to act_mirred?

