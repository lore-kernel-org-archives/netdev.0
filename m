From: David Miller <davem@davemloft.net>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 15:29:59 -0400 (EDT)
Message-ID: <20160328.152959.1109841569654352040.davem@davemloft.net>
References: <56F8987B.5030501@gmail.com>
	<56F92E21.30509@gmail.com>
	<alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sploving1@gmail.com, pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbcC1TaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 15:30:02 -0400
In-Reply-To: <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Mon, 28 Mar 2016 18:48:51 +0200 (CEST)

>> > > @@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
>> > >               length--;
>> > >               continue;
>> > >           default:
>> > > +            if (length < 2)
>> > > +                return;
>> > >               opsize = *ptr++;
>> > >               if (opsize < 2) /* "silly options" */
>> > >                   return;

I'm trying to figure out how this can even matter.

If we are in the loop, length is at least one.

That means it is legal to read the opsize byte.

By the next check, opsize is at least 2.

And then the very next line in this code makes sure length >= opsize:

			if (opsize > length)
				return;	/* don't parse partial options */

Therefore no out-of-range access is possible as far as I can see.
