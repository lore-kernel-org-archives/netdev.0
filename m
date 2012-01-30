From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: increase the number of routing tables
Date: Mon, 30 Jan 2012 13:44:24 +0100
Message-ID: <1327927464.2288.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
	 <1327804887.2805.20.camel@edumazet-laptop>
	 <20120130122546.GE8376@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Chen <simonchennj@gmail.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56675 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab2A3Mo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 07:44:28 -0500
Received: by bkas6 with SMTP id s6so3119701bka.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 04:44:27 -0800 (PST)
In-Reply-To: <20120130122546.GE8376@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 janvier 2012 =C3=A0 07:25 -0500, Thomas Graf a =C3=A9crit :

> I've run into these scalability issues a while ago which is
> why I've added the goto action allowing to build a tree like
> structures:
>=20
> 0:	from all lookup local=20
> 10:     from eth0 goto 4000
> [possibly thousands of rules]
> 3999:   from all goto 32763
> 4000:   from all to 1.1.1.1 lookup foo
> [...]
> 32763:	from all to 1.2.3.7 lookup test3000=20
> 32766:	from all lookup main=20
> 32767:	from all lookup default=20

Indeed, but make sure to use a recent kernel (3.2) so that Yan Zheng an=
d
Gao Feng fixes are in :)

commit afaef734e5f0 (fib_rules: fix unresolved_rules counting)
commit 561dac2d410f (fib:fix BUG_ON in fib_nl_newrule when add new fib
rule)

commit ebb9fed2def (fib: fix fib_nl_newrule())
