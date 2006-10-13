From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Fri, 13 Oct 2006 22:13:45 +0200
Message-ID: <452FF379.2080600@cosmosbay.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP> <452E69B2.4030306@hp.com>
 <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
 <452EC7B9.2030801@hp.com> <452F11E4.8050508@cosmosbay.com>
 <452FC15D.7030902@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604002mt.neufgp.fr ([84.96.92.61]:49883 "EHLO sMtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1751877AbWJMUNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 16:13:46 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604002mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7300N89C6X2320@sp604002mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 13 Oct 2006 22:13:45 +0200 (CEST)
In-reply-to: <452FC15D.7030902@hp.com>
To: Rick Jones <rick.jones2@hp.com>, Martin Schiller <mschiller@tdt.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
> Eric Dumazet wrote:
>> Rick Jones a =E9crit :
>>
>>>> More to the point, on what basis would the application be rejectin=
g a
>>>> connection request based solely on the SYN?
>>>
>>>
>>> True, it isn't like there would suddenly be any call user data as i=
n=20
>>> XTI/TLI.
>>
>>
>> DATA payload could be included in the SYN packet. TCP specs allow th=
is=20
>> AFAIK.
>=20
> Yes, but it isn't supposed to be delivered until the 3-way handshake =
is=20
> complete right?

Are you speaking of 20 years old BSD API ? :)

Martin, I played with libnetfilter_queue=20
(http://www.netfilter.org/projects/libnetfilter_queue/index.html)

With this single iptables rules, I was able to do what you want : trans=
mit the=20
SYN message to a user application, that may DROP this packet or let it =
pass=20
normal TCP stack.

iptables -A INPUT -p tcp --dport 333 --syn -j QUEUE

Then hack nfqnl_test.c to meet your needs (see nfq_set_verdict(),=20
nfq_get_payload())

Be prepared to receive the 'same SYN' several time if your X.25 call at=
tempt=20
is too long.

(You have to be root unfortunatly)

Eric

