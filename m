From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: Use symmetric hash for PACKET_FANOUT_HASH.
Date: Sat, 02 Jul 2016 16:38:25 -0400 (EDT)
Message-ID: <20160702.163825.1446208948440189011.davem@davemloft.net>
References: <CALx6S34B33PUMfk4R662_WEjiafjheNbH=wH9r=QhYTK14nmqw@mail.gmail.com>
	<20160701.170701.1456256736115514983.davem@davemloft.net>
	<CALx6S37Gn3SL9XucQ8+9MM78TOyEYQHV6bKyCEgQ+trg4e_Xmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org, victor@inliniac.net
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:39288 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751420AbcGBUi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 16:38:28 -0400
In-Reply-To: <CALx6S37Gn3SL9XucQ8+9MM78TOyEYQHV6bKyCEgQ+trg4e_Xmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 1 Jul 2016 14:16:54 -0700

> On Fri, Jul 1, 2016 at 2:07 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Fri, 1 Jul 2016 13:52:58 -0700
>>
>>> Why are symmetric hashes required?
>>
>> Because they want load balancing, such that one flow only can overrun
>> one single socket not all of the ones in the fanout.
>>
> I'm still missing it. Why is this any different than what we need with
> something like SO_REUSEPORT?

Because local sockets only demux on RX packets for a flow so they
don't need a symmetric hash, and in fact wouldn't even notice if the
hash was symmetric or not.

Programs like suricata that are operating as a bump in the stack see
both directions of traffic for a flow and therefore for them whether
the hash is symmetric is an issue.
