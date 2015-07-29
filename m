From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len
 configurable
Date: Wed, 29 Jul 2015 14:37:31 -0700 (PDT)
Message-ID: <20150729.143731.834219016906219771.davem@davemloft.net>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
	<20150729210618.GF32705@breakpoint.cc>
	<20150729213428.GC15554@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, brouer@redhat.com,
	cwang@twopensource.com, eric.dumazet@gmail.com
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbbG2Vhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:37:32 -0400
In-Reply-To: <20150729213428.GC15554@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 29 Jul 2015 23:34:28 +0200

> On Wed, Jul 29, 2015 at 11:06:18PM +0200, Florian Westphal wrote:
>> Phil Sutter <phil@nwl.cc> wrote:
> [...]
>> > +config DEFAULT_TX_QUEUE_LEN
>> > +	prompt "Default TX queue length (in packets)" if EXPERT
>> > +	int
>> > +	default 1000	# Ethernet wants good queues
>> > +	help
>> > +	  Set the default value of tx_queue_len for newly created network
>> > +	  interfaces. It is used by queueing disciplines to determine how many
>> > +	  packets to keep in backlog before starting to drop new ones.
>> > +
>> > +	  The default value of 1000 packets is there for a very long time and
>> > +	  in combination with GSO way too big.
>> > +
>> 
>> I can't see how this could be used in a meaningful way.
>> 
>> No distro is going to touch this.
>> 
>> I don't think sysctl value would help either.
> 
> I just didn't want to introduce yet another magic value assignment. It's
> merely a #define with a little flexibility and a subtle note that the
> default should be changed attached.

Like others have mentioned, fix the _REAL_ issue.

Which is that there are devices (virtual or whatever) which don't want
a qdisc attached no matter what.  Flag those devices as such and
adjust the qdisc attachment logic to check that new flag.

Anything is better than hacking the queue len.
