From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Tue, 03 Feb 2009 22:05:20 +0100
Message-ID: <4988B190.2060300@cosmosbay.com>
References: <20090130215700.965611970@vyatta.com>	<20090130215729.416851870@vyatta.com>	<498594B6.6000905@cosmosbay.com>	<20090202153357.3ac6edfa@extreme>	<49889440.60702@cosmosbay.com>	<20090203193214.GH6607@linux.vnet.ibm.com>	<4988A6F4.6000902@cosmosbay.com> <20090203124442.44598d63@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41531 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZBCVId convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 16:08:33 -0500
In-Reply-To: <20090203124442.44598d63@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
>>
>> General/intuitive idea would be :
>>
>> switch pointers to a newly allocated table (and zeroed counters)
>> wait one RCU grace period
>> collect/sum all counters of "old" table + (all cpus) into user provi=
ded table
>> restore previous table
>> wait one RCU grace period
>> disable_bh()
>> collect/sum all counters of "new and temporary" table (all cpus) and
>> reinject them into local cpu table (this cpu should not be interrupt=
ed)
>> enable_bh()
>>
>> This way, "iptables -L" is not too expensive and doesnt block packet=
 processing at all.
>=20
> Pretty much what I said.


Cool then, sorry for misunderstanding your patch.

