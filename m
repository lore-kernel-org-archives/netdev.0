From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH v3 1/2] core: Factor out flow calculation from
 get_rps_cpu
Date: Tue, 03 Aug 2010 15:36:10 -0700
Message-ID: <1280874970.17972.51.camel@w-sridhar.beaverton.ibm.com>
References: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com>
	 <AANLkTikJMih-CAA_d95ot0z57EOhMFsiNc2nnki6v6LY@mail.gmail.com>
	 <AANLkTimP_0e5UMC7mgn9=g=kyhqaghdEZC61=Tx7OesP@mail.gmail.com>
	 <201008031032.16138.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	bhutchings@solarflare.com, davem@davemloft.net, mst@redhat.com,
	netdev@vger.kernel.org, therbert@google.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:48041 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757344Ab0HCWgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 18:36:22 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o73MWhPV005723
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 16:32:43 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o73MaEmE063990
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 16:36:15 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o73MaCZL025423
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 16:36:13 -0600
In-Reply-To: <201008031032.16138.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-03 at 10:32 +0200, Arnd Bergmann wrote:
> On Tuesday 03 August 2010, Changli Gao wrote:
> > > I am confused by the call sites of macvlan_dev.receive and
> > > macvlan_dev.forward. They both are possible to be called in both
> > > RX(skb->data points to network header) and TX(skb->data points to
> > > ethernet) paths. The current code in macvtap shows that
> > > macvlan_dev.receive should be called in network layer, and
> > > macvlan_dev.forward should be called in dev layer. Am I correct?
> > >
> > 
> > After checking the code carefully, I find macvlan_dev.receive is
> > called in network layer(RX path), and macvlan_dev.forward is called in
> > dev layer(TX path). The current code hasn't any issue. Your solution
> > won't work, as macvtap_forward is called in dev layer, when skb->data
> > points to ethernet header already.
> 
> Yes, that is correct. Forward is used for "bridge" mode, where we
> can send data between two macvlan/macvtap endpoints directly, as
> opposed to the default "vepa" mode, where all data is always sent
> out to the lowerdev and may be returned by an adjacent switch in
> hairpin configuration.

macvtap_forward() is also used in the normal receive path as
macvtap_receive() has a direct call to macvtap_forward() after 
updating skb->data to point to the ethernet header.

Thanks
Sridhar

