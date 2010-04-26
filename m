From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] TCP: avoid to send keepalive probes if receiving
 data
Date: Mon, 26 Apr 2010 11:24:22 -0700 (PDT)
Message-ID: <20100426.112422.246526700.davem@davemloft.net>
References: <20100425235549.GB2550@sysclose.org>
	<1272249659-2292-1-git-send-email-fleitner@redhat.com>
	<alpine.DEB.2.00.1004261241510.7041@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fleitner@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751986Ab0DZSYQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 14:24:16 -0400
In-Reply-To: <alpine.DEB.2.00.1004261241510.7041@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 26 Apr 2010 12:47:13 +0300 (EEST)

>>  			    !((1 << sk->sk_state) &
>>  			      (TCPF_CLOSE | TCPF_LISTEN))) {
>> -				__u32 elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
>> +				u32 elapsed =3D min_t(u32,
>> +				      tcp_time_stamp - icsk->icsk_ack.lrcvtime,
>> +				      tcp_time_stamp - tp->rcv_tstamp);
>> +
>=20
> I'd put this into a helper in include/net/tcp.h
>=20
 ...
>> +	if (elapsed < keepalive_time_when(tp)) {
>> +		elapsed =3D keepalive_time_when(tp) - elapsed;
>> +		goto resched;
>> +	}
>> +
>>  	elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
>=20
> ...And then use it here too for setting the elapsed and doing the tes=
t=20
> and what follows only once?
>=20

Agreed.
