From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Fri, 01 May 2009 09:47:24 +0200
Message-ID: <49FAA90C.2080201@cosmosbay.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>	 <20090430.022417.07019547.davem@davemloft.net>	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>	 <20090430.070811.260649067.davem@davemloft.net>	 <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com> <606676310904302119w92e610crbdb7d5d824e6ed01@mail.gmail.com> <49FAA570.2040802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: Andrew Dickinson <andrew@whydna.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56195 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbZEAHrd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 03:47:33 -0400
In-Reply-To: <49FAA570.2040802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Andrew Dickinson a =E9crit :
>> Adding a bit more info...
>>
>> I should add, the other 4 ksoftirqd tasklets _are_ running, they're
>> just not busy. (In case that wasn't clear...)
>>
>> Also of note, I rebooted the box (after recompiling with NUMA off).
>> This time when I push traffic through, only the even-ksoftirqd's wer=
e
>> busy..  I then tweaked some of the ring settings via ethtool and
>> suddenly the odd-ksoftirqd's became busy (and the even ones went
>> idle).
>>
>> Thoughts?  Suggestions?  driver issue?  I'm at 2.6.30-rc3.
>>
>> (BTW, I'm under the assumption that since only 4 (of 8) ksoftirqd's
>> are busy that I still have room to make this box go faster).
>=20
> I dont see the point here. ksoftirqd is running only if too much
> work has to be done in softirq context. Which should be your case
> since you want to saturate cpus with network load.
>=20
> You could try to change /proc/sys/net/core/netdev_budget if you reall=
y
> want to trigger ksoftirqd sooner or later, but it wont fundamentally
> change routing performance.
>=20
> If you believe box is loosing frames because cpu are saturated, pleas=
e
> post some oprofile results.

My random feeling is you might have a dst_release() contention, but my
feeling might be wrong, I dont know what kind of network load you reall=
y
use...


