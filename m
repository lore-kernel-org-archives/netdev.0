From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net-next: lockdep complains re percpu counters
Date: Tue, 02 Dec 2008 09:29:22 +0100
Message-ID: <4934F1E2.3020409@cosmosbay.com>
References: <20081130130726.GA4365@x200.localdomain>	<4932C128.6040401@cosmosbay.com> <20081201.233748.204870635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59737 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbYLBI31 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:29:27 -0500
In-Reply-To: <20081201.233748.204870635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 30 Nov 2008 17:36:56 +0100
>=20
>> [PATCH] net: percpu_counter_inc() should not be called in BH-disable=
d section
>>
>> I checked all per_cpu_counter_xxx() usages in network tree, and I th=
ink
>> all call sites are BH enabled except one in inet_csk_listen_stop().
>>
>> commit dd24c00191d5e4a1ae896aafe33c6b8095ab4bd1
>> (net: Use a percpu_counter for orphan_count)
>> replaced atomic_t orphan_count to a percpu_counter.
>>
>> atomic_inc()/atomic_dec() can be called from any context, while perc=
pu_counter_xxx()
>> should be called from a consistent state.
>>
>> For orphan_count, this context can be the BH-enabled one.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> I applied this preemptively even though Alexey hasn't given
> test feedback yet, and I also added a mention of his report
> in the commit message.

Hum, this patch was necessary but wont help Alexy case that was
not related, if I undertsnad well its oops.

Its oops was about nr_files and a network percpu_counter, one
always called in BH-enabled context, one always in BD-disabled context.

We need a core change here, so that lockdep dont assume all percpu_coun=
ter
have the same class.

I know nothing about lockdep so a fix could take me some time, one
can beat me easily ;)


