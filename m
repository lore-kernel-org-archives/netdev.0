From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Performance problem in network namespaces
Date: Wed, 5 May 2010 09:37:06 +0200
Message-ID: <z2zb9800b71005050037t3e5bd32md7bb2c855be4943f@mail.gmail.com>
References: <q2tb9800b71005030225q21365e3ch8dd5b35383a32e8a@mail.gmail.com>
	 <m3y6g0m204.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36242 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab0EEHhI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 03:37:08 -0400
Received: by pva18 with SMTP id 18so332635pva.19
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 00:37:06 -0700 (PDT)
In-Reply-To: <m3y6g0m204.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Benny,

On Tue, May 4, 2010 at 11:48, Benny Amorsen <benny+usenet@amorsen.dk> w=
rote:

>> When running some benchmarks to test the feasibility of using
>> namespaces for emulating networks, I have found a big drop in
>> performance when one of the namespaces is performing routing of
>> packets.

> Is this problem specific to vnet, or do the other types of interfaces
> suffer from it as well? (phys, vlan, macvlan...)

Seems that it is specific to vnet, but if there's other way of having
datagrams created locally that get into the routing code before
leaving the system, maybe that would have the same problem.

I tried a couple of combinations that somehow included routing in the m=
ix:
- routing loop over the same ethernet device (e1000e)
- routing between eth and wlan (iwlagn)
- eth and veth (with the paired veth inside a different namespace)
- wlan and veth (ditto)

In all those cases, I see that in ip_forward() the headroom is already
enough, and I think is due to the fact that the hardware drivers use
netdev_alloc_skb which already adds NET_SKB_PAD to the length
requested.

Using macvlan over the real devices showed the same results.

I also tried:
- eth and wlan: packets arriving from eth had a headroom  of 48, but
80 was needed to pass it to wlan

--=20
Mart=EDn Ferrari
