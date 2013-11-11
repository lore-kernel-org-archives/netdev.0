From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 18:44:56 +0100
Message-ID: <52811798.1060805@openwrt.org>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>		<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>		<21120.29720.673157.151074@gargle.gargle.HOWL>		<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>		<21120.37647.979237.40802@gargle.gargle.HOWL>		<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>	 <21121.575.539384.948990@gargle.gargle.HOWL> <52810800.9020402@openwrt.org> <1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sujith Manoharan <sujith@msujith.org>, netdev@vger.kernel.org,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:37373 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754705Ab3KKRpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 12:45:12 -0500
In-Reply-To: <1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-11-11 18:38, Eric Dumazet wrote:
> On Mon, 2013-11-11 at 17:38 +0100, Felix Fietkau wrote:
>> I don't think this issue is about something as simple as timer handling
>> for tx completion (or even broken/buggy drivers).
>> 
>> There's simply no way to make 802.11 aggregation work well and have
>> similar tx completion latency characteristics as Ethernet devices.
>> 
>> 802.11 aggregation reduces the per-packet airtime overhead by combining
>> multiple packets into one transmission (saving a lot of time getting a
>> tx opportunity, transmitting the PHY header, etc.), which makes the
>> 'line rate' heavily depend on the amount of buffering.
> 
> How long a TX packet is put on hold hoping a following packet will
> come ?
TX packets in the aggregation queue are held as long as the hardware
queue holds two A-MPDUs (each of which can contain up to 32 packets).
If the aggregation queues are empty and the hardware queue is not full,
the next tx packet from the network stack is pushed to the hardware
queue immediately.

- Felix
