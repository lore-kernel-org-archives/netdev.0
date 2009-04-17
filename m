From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loopback: packet drops accounting
Date: Fri, 17 Apr 2009 11:27:53 +0200
Message-ID: <49E84B99.1080502@cosmosbay.com>
References: <49E78DE5.10104@hartkopp.net>	<20090417.013853.04495551.davem@davemloft.net>	<49E84459.1060507@cosmosbay.com> <20090417.015914.09817926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44667 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696AbZDQJ2D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:28:03 -0400
In-Reply-To: <20090417.015914.09817926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 17 Apr 2009 10:56:57 +0200
>=20
>> We can in some situations drop packets in netif_rx()
>>
>> loopback driver does not report these (unlikely) drops to its stats,
>> and incorrectly change packets/bytes counts.
>>
>> After this patch applied, "ifconfig lo" can reports these drops as i=
n :
>>
>> # ifconfig lo
>> lo        Link encap:Local Loopback
>>           inet addr:127.0.0.1  Mask:255.0.0.0
>>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>>           RX packets:692562900 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:692562900 errors:3228 dropped:3228 overruns:0 c=
arrier:0
>>           collisions:0 txqueuelen:0
>>           RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 Gi=
B)
>>
>> I chose to reflect those errors only in tx_dropped/tx_errors, and no=
t mirror
>> these errors in rx_dropped/rx_errors.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Well, logically the receive is what failed, not the transmit.
>=20
> I think it's therefore misleading to count it as a TX drop.
>=20
> Do you feel strongly about this?

Not at all, but my plan was to go a litle bit further, ie being able to=
=20
return from loopback_xmit() with a non null value.

netif_rx() usage in loopback device is biased, since its really a trans=
mit :)

Oh well...

