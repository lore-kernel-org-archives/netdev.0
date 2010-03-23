From: Mihamina Rakotomandimby <mihamina@gulfsat.mg>
Subject: Re: tc download always to "default" [solved]
Date: Tue, 23 Mar 2010 10:02:07 +0300
Message-ID: <20100323100207.705ecef8@pbmiha.malagasy.com>
References: <20100322134309.53fe1bb3@pbmiha.malagasy.com>
 <20100322143113.GA23778@wolff.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-104-36.blueline.mg ([41.204.104.36]:41652 "EHLO
	mail.blueline.mg" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754621Ab0CWHCV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 03:02:21 -0400
Received: from localhost (static-104-53.blueline.mg [41.204.104.53])
	by mail.blueline.mg (Postfix) with ESMTP id 12B9DFD29
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 10:02:19 +0300 (EAT)
Received: from mail.blueline.mg ([41.204.104.38])
	by localhost (antivirus2.malagasy.com [41.204.104.53]) (amavisd-new, port 10024)
	with ESMTP id HgRmwRSQNFnZ for <netdev@vger.kernel.org>;
	Tue, 23 Mar 2010 10:02:08 +0300 (EAT)
Received: from pbmiha.malagasy.com (sysadmin-cnc.malagasy.com [41.204.104.9])
	by mail.blueline.mg (Postfix) with ESMTP id 94C3EF826
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 10:02:13 +0300 (EAT)
Received: from localhost ([127.0.0.1] helo=pbmiha.malagasy.com)
	by pbmiha.malagasy.com with esmtp (Exim 4.69)
	(envelope-from <mihamina@gulfsat.mg>)
	id 1Nty7s-0000vr-2g
	for netdev@vger.kernel.org; Tue, 23 Mar 2010 10:02:08 +0300
In-Reply-To: <20100322143113.GA23778@wolff.to>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Bruno Wolff III <bruno@wolff.to> :
>> My problem is all the traffic is caught by "classid 1:10", the
>> default class.
>> Nothing is trapped by "classid 1:301" -> "classid 1:426"
>> At a first glance, would you see something wrong in these?
>I took a quick look and didn't see anything obvious. But I haven't
>played with this stuff for a while and my scripts were set up a bit
>differently.
>How are you checking that everything is ending up in the default class=
?

1=C2=B0) As I wrote my rules, each IP address has one handler.
I use this script to display UP and DOWN traffic for the handler in $1:

  #!/bin/sh

  INIF=3Deth1
  OUTIF=3Difb0

  RATEIN=3D$(tc -s -d class show dev $INIF \
    | egrep -A 5 "class htb 1:$1 " \
    | egrep "rate .+ backlog" \
    | awk '{print $2}')
 =20
  RATEOUT=3D$(tc -s -d class show dev $OUTIF \
    | egrep -A 5 "class htb 1:$1 " \
    | egrep "rate .+ backlog" \
    | awk '{print $2}')

  echo $RATEIN
  echo $RATEOUT

I launch it like this:
# get-bw.sh $NNN
Where $NNN is the handler.

When I launch it, I see "0bit" for IN traffic, that means nothing is
trapped.
When I launch it with the handler of the default, I see much traffic.

2=C2=B0) When varying the "default" allocated bandwidth, I see in my ch=
arts
it is the one seen.

>I remember there is a command that tells you how much stuff is ending
> up getting handled by the different qdiscs. Is that what you are doin=
g
> or are you just assuming that's what's happening because traffic isn'=
t
> being limited the way you expect?

Anyway, I solved my problem:
The LAN interface is "eth1" but there is a tunnel "tun0" coupled to it
(I use coova chilli access point).
Just to test, I switched to "tun0" and it suddenly worked.

In all the rules I gave, just replacing "eth1" with "tun0" made it!
(What a dumb I am...)

Thanks for everything.

--=20
       Architecte Informatique chez Blueline/Gulfsat:
    Administration Systeme, Recherche & Developpement
                +261 34 29 155 34 / +261 33 11 207 36
