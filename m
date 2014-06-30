From: Stefan Wahren <info@lategoodbye.de>
Subject: Re: Packet loss when txqueuelen is zero
Date: Mon, 30 Jun 2014 19:08:16 +0200
Message-ID: <53B19980.7050606@lategoodbye.de>
References: <53AEA00F.6060500@lategoodbye.de>	 <1403966418.15139.27.camel@edumazet-glaptop2.roam.corp.google.com>	 <53B019E5.4060905@lategoodbye.de> <1404107363.15139.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.augenpunkt.de ([213.239.207.9]:49230 "EHLO
	www.augenpunkt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbaF3Qvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 12:51:53 -0400
In-Reply-To: <1404107363.15139.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Am 30.06.2014 07:49, schrieb Eric Dumazet:
> On Sun, 2014-06-29 at 15:51 +0200, Stefan Wahren wrote:
>
>> But fq_codel requires BQL in the QCA7000 network driver. Right?
>
> Not at all. 10 skb in TX ring is very small, BQL wont really help in
> this case.
>
> BQL is good for NIC with TSO support, mostly.
>

Dave T=C3=A4ht made the suggestion to reduce the skbs to 2. But i'm not=
 sure=20
if it's a good solution, because the SPI overhead becomes bigger.

I have another idea. The QCA has an internal tx buffer something above=20
3000 bytes. So it would be helpful if the tx ring stores the estimated=20
byte size of all skbs. In the case this sum is so big that skb with a=20
MTU (1500 byte) won't fit into the QCA buffer, the tx queue can be stop=
ped.

I commited my implementation [1] in the morning.

[1] -=20
https://github.com/I2SE/qca7000/commit/4539475a4ce1d0f5ab6ed111df9d2a9a=
b5f9bcc3
