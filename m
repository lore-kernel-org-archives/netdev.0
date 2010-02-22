From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Sun, 21 Feb 2010 18:10:29 -0800 (PST)
Message-ID: <20100221.181029.71107197.davem@davemloft.net>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: damian@tvk.rwth-aachen.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43434
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754362Ab0BVCKL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 21:10:11 -0500
In-Reply-To: <alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 16 Feb 2010 14:45:25 +0200 (EET)

> On Wed, 10 Feb 2010, Damian Lukowski wrote:
>=20
>> @@ -5783,12 +5783,10 @@ int tcp_rcv_state_process(struct sock *sk, s=
truct sk_buff *skb,
>> =20
>>  				/* tcp_ack considers this ACK as duplicate
>>  				 * and does not calculate rtt.
>> -				 * Fix it at least with timestamps.
>> +				 * Force it here.
>>  				 */
>> -				if (tp->rx_opt.saw_tstamp &&
>> -				    tp->rx_opt.rcv_tsecr && !tp->srtt)
>> -					tcp_ack_saw_tstamp(sk, 0);
>> -
>> +				tcp_ack_update_rtt(sk, 0, 0);
>> +
>=20
> ...Here a zero seq_rtt is given to RTT estimator (it will be effectiv=
e=20
> only in the case w/o timestamps, TS case recalculates it from the sto=
red=20
> timestamps). Maybe we could use some field (timestamp related one com=
es to=20
> my mind) in request sock to get a real RTT estimate for non-timestamp=
 case=20
> too. ...It seems possible to me, though tricky because the request_so=
ck is=20
> no longer that easily available here so some parameter passing would =
be=20
> needed.

Agreed.

But even more simply I think we should make even the current
tcp_ack_update_rtt() call here conditional on at least
tp->srtt being zero.

Damian do you at least agree with that?
