From: David Miller <davem@davemloft.net>
Subject: Re: VLAN I/F's and TX queue.
Date: Sun, 16 May 2010 00:40:41 -0700 (PDT)
Message-ID: <20100516.004041.73702151.davem@davemloft.net>
References: <OF803EE436.793B95D8-ONC125771C.003295C9-C125771C.00341AFF@transmode.se>
	<4BE8191C.8020302@trash.net>
	<OFC83B46CB.0E764A8E-ONC125771F.005109E4-C125771F.00518338@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751913Ab0EPHkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 03:40:33 -0400
In-Reply-To: <OFC83B46CB.0E764A8E-ONC125771F.005109E4-C125771F.00518338@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Mon, 10 May 2010 16:50:20 +0200

> Patrick McHardy <kaber@trash.net> wrote on 2010/05/10 16:33:00:
>>
>> Joakim Tjernlund wrote:
>> > Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/05/07 10:53:23:
>> >>> 3) I would expect lost pkgs to be accounted on eth0 instead of
>> >>>    the VLAN interface(s) since that is where the pkg is lost, why
>> >>>    isn't it so?
>> >> You try to send packets on eth0.XXX, some are dropped, and accounted for
>> >> on eth0.XXX stats. What is wrong with this ?
>> >
>> > In this case one lost pkg is accounted for twice, once on eth0.1 and
>> > once more on eth0.1.1. Note that eth0.1.1 is stacked on
>> > top of eth0.1
>> >
>> > I would at least expect eth0 to also account lost pkgs too.
>> > I was confused by the current accounting as I knew that
>> > the underlying HW I/F should be the only I/F that could
>> > drop pkgs.
>>
>> In case of NET_XMIT_CN, the packet is dropped by the qdisc before
>> it reaches eth0, so its only accounted on the upper devices.
> 
> hmm, I am afraid I don't follow this. Why would a pkg be dropped before
> it reaches eth0?

Because we have packet schedulers that sit before the device transmit
happens, and those packet schedulers enforce limits based upon
classification results or other criteria, and if those limits are
exceeded packets are droppers and NET_XMIT_CN is returned back up into
the transmit path of the networking stack.

The device never sees that packet get submitted to it's ->ndo_start_xmit()
routine, and this is entirely intentional.  And it is entirely intentional
that NET_XMIT_CN gets passed up into the caller, where protocols such as
TCP can key off this information to make congestion control decisions.

