From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Wed, 21 Dec 2011 14:41:26 -0500 (EST)
Message-ID: <20111221.144126.2213051521357190879.davem@davemloft.net>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	<1324495344.2621.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xi.wang@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615Ab1LUTla convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:41:30 -0500
In-Reply-To: <1324495344.2621.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 20:22:24 +0100

> Le mercredi 21 d=E9cembre 2011 =E0 13:50 -0500, Xi Wang a =E9crit :
>> @@ -665,7 +665,7 @@ static ssize_t store_rps_dev_flow_table_cnt(stru=
ct netdev_rx_queue *queue,
>>  	if (count) {
>>  		int i;
>> =20
>> -		if (count > 1<<30) {
>> +		if (count > 1<<28) {
>>  			/* Enforce a limit to prevent overflow */
>>  			return -EINVAL;
>>  		}
>=20
>=20
> Really, you should remove this magic number and use instead
>=20
> (INT_MAX - RPS_DEV_FLOW_TABLE_SIZE(0)) / sizeof(struct rps_dev_flow)
>=20
> Or something like that, because next time we add a field in
> rps_dev_flow, test will be obsolete.

Agreed.
