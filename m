From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] rtnetlink & bonding: change args got
 get_tx_queues
Date: Wed, 11 Apr 2012 08:20:54 -0700
Message-ID: <20120411082054.2bf6a352@nehalam.linuxnetplumber.net>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
	<1334009344.7150.268.camel@deadeye>
	<20120410213443.31fc0784@nehalam.linuxnetplumber.net>
	<1334123747.5300.2197.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42008 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753479Ab2DKPU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 11:20:58 -0400
In-Reply-To: <1334123747.5300.2197.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Apr 2012 07:55:47 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2012-04-10 at 21:34 -0700, Stephen Hemminger wrote:
> > Change get_tx_queues, drop unsused arg/return value real_tx_queues,
> > and use return by value (with error) rather than call by reference.
> > 
> > Probably bonding should just change to LLTX and the whole get_tx_queues
> > API could disappear!
> 
> Absolutely ;)
> 
> 

It is more complex than that (actually the bonding driver is a mess).
The bonding device is already using Lockless Transmit and transmit queue length
of zero (good), but it then does some queue mapping of it's own which
is unnecessary.

Multiqueue only makes sense if there is a queue, otherwise the skb
can transparently pass through the layered device (vlan, bridge, bond)
and get queued on the real physical device.

Right now, trying to see if there is any impact by just leaving
bond device as single queue.
