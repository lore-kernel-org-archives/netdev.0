From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Tue, 3 Aug 2010 10:32:15 +0200
Message-ID: <201008031032.16138.arnd@arndb.de>
References: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com> <AANLkTikJMih-CAA_d95ot0z57EOhMFsiNc2nnki6v6LY@mail.gmail.com> <AANLkTimP_0e5UMC7mgn9=g=kyhqaghdEZC61=Tx7OesP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, bhutchings@solarflare.com,
	davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	therbert@google.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58977 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288Ab0HCIc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 04:32:27 -0400
In-Reply-To: <AANLkTimP_0e5UMC7mgn9=g=kyhqaghdEZC61=Tx7OesP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 August 2010, Changli Gao wrote:
> > I am confused by the call sites of macvlan_dev.receive and
> > macvlan_dev.forward. They both are possible to be called in both
> > RX(skb->data points to network header) and TX(skb->data points to
> > ethernet) paths. The current code in macvtap shows that
> > macvlan_dev.receive should be called in network layer, and
> > macvlan_dev.forward should be called in dev layer. Am I correct?
> >
> 
> After checking the code carefully, I find macvlan_dev.receive is
> called in network layer(RX path), and macvlan_dev.forward is called in
> dev layer(TX path). The current code hasn't any issue. Your solution
> won't work, as macvtap_forward is called in dev layer, when skb->data
> points to ethernet header already.

Yes, that is correct. Forward is used for "bridge" mode, where we
can send data between two macvlan/macvtap endpoints directly, as
opposed to the default "vepa" mode, where all data is always sent
out to the lowerdev and may be returned by an adjacent switch in
hairpin configuration.

	Arnd
