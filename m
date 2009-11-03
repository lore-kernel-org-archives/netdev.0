From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Tue, 3 Nov 2009 17:47:17 +0800
Message-ID: <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com> <20091103080022.GA6718@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:48745 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbZKCJrM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:47:12 -0500
Received: by pwj9 with SMTP id 9so2400760pwj.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 01:47:17 -0800 (PST)
In-Reply-To: <20091103080022.GA6718@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2009 at 4:00 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
>
>> It means that a class, which sends packets
>> in ceil rate, can also enter HTB_CAN_SEND state now and then.
>
> Yes, a class is entitled to send on it's own then with it's guarantee=
d
> rate, without depending on borrowing.

I don't think so. The class should _NOT_ enter HTB_CAN_SEND mode when
its data rate is higher than its rate specification. In other word, a
class should enter HTB_CAN_SEND mode only when its data rate isn't
higher than its rate specification. Otherwise, it will get additional
tokens and reach a higher data rate than its ceil specification. This
may affect other classes.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
