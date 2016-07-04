From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH] packet: Use symmetric hash for PACKET_FANOUT_HASH.
Date: Mon, 4 Jul 2016 10:41:07 +0200
Message-ID: <577A2123.8020005@inliniac.net>
References: <CALx6S34B33PUMfk4R662_WEjiafjheNbH=wH9r=QhYTK14nmqw@mail.gmail.com>
 <20160701.170701.1456256736115514983.davem@davemloft.net>
 <CALx6S37Gn3SL9XucQ8+9MM78TOyEYQHV6bKyCEgQ+trg4e_Xmg@mail.gmail.com>
 <20160702.163825.1446208948440189011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, eric@regit.org
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:55014 "EHLO
	mail.inliniac.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189AbcGDIsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 04:48:46 -0400
In-Reply-To: <20160702.163825.1446208948440189011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02-07-16 22:38, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Fri, 1 Jul 2016 14:16:54 -0700
> 
>> On Fri, Jul 1, 2016 at 2:07 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Tom Herbert <tom@herbertland.com>
>>> Date: Fri, 1 Jul 2016 13:52:58 -0700
>>>
>>>> Why are symmetric hashes required?
>>>
>>> Because they want load balancing, such that one flow only can overrun
>>> one single socket not all of the ones in the fanout.
>>>
>> I'm still missing it. Why is this any different than what we need with
>> something like SO_REUSEPORT?
> 
> Because local sockets only demux on RX packets for a flow so they
> don't need a symmetric hash, and in fact wouldn't even notice if the
> hash was symmetric or not.
> 
> Programs like suricata that are operating as a bump in the stack see
> both directions of traffic for a flow and therefore for them whether
> the hash is symmetric is an issue.

Tools like Suricata, Bro, Snort, netsniff-ng are often used to sit on
the side and receive a copy of the traffic from a tap or span port. This
leads to both sides of connections coming in on the RX side. As the said
tools often rely on the hashing for load balancing to multiple
threads/processes, the hashing should be done symmetrically.

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------
