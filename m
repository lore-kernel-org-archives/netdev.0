From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: about tx_queue_len for phonet driver
Date: Thu, 12 Jan 2012 13:56:28 +0200
Message-ID: <2151675.UOkxvXJjp1@hector>
References: <81C3A93C17462B4BBD7E272753C105791FB10F9968@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:35162 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860Ab2ALLzn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 06:55:43 -0500
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791FB10F9968@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

Le Jeudi 12 Janvier 2012 11:45:48 ext Hemant-vilas RAMDASI a =E9crit :
> Can anyone guide me about when should a network driver set tx_queue_l=
en to
> 0? We are facing a network congestion issue with phonet packets where=
 one
> of the control message packet is dropped because of congestion. In ou=
r
> phonet network driver the tx_queue_len is set to 3 (taken from usb-ph=
onet
> mostly). If phonet cannot handle packet-drop (for pipe messages), the=
n
> should network driver always set tx_queue_len as 0?

In theory, I guess the network device queuing discipline should be avoi=
ded=20
altogether, unless there is another way to prevent packet loss, that I =
am not=20
aware of. Unfortunately dropping qdisc, and thus net_device also, would=
 have=20
major redesign implications on the Linux Phonet infrastructure to say t=
he=20
least.

In any case, Phonet devices typically fail to provide sane, reliable an=
d race-
free congestion control. I have seen some Phonet modem firmwares that j=
ust=20
crash if they receive too many and/or too large packets. Alas, this can=
not be=20
fixed on the Linux / application processor side.


So you have to find a value large enough to avoid packet loss, but also=
 small=20
enough to avoid overflow and who-knows-what bugs on the modem side. For=
 the=20
record, the SSI driver queue length found on Nokia N9/N950 defaults to =
100.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
