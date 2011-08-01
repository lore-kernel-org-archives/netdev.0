From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Mon, 01 Aug 2011 20:37:46 +0200
Message-ID: <1312223866.2719.3.camel@edumazet-laptop>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
	 <20110801181652.GB2732@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rui Ueyama <rui314@gmail.com>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59338 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780Ab1HASiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 14:38:01 -0400
Received: by wwe5 with SMTP id 5so5934174wwe.1
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 11:38:00 -0700 (PDT)
In-Reply-To: <20110801181652.GB2732@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 ao=C3=BBt 2011 =C3=A0 20:16 +0200, Hagen Paul Pfeifer a =C3=
=A9crit :
> * Rui Ueyama | 2011-07-29 01:10:26 [-0700]:
>=20
> >Convert the BPF VM to threaded code to improve performance.
> >
> >The BPF VM is basically a big for loop containing a switch statement=
=2E  That is
> >slow because for each instruction it checks the for loop condition a=
nd does the
> >conditional branch of the switch statement.
> >
> >This patch eliminates the conditional branch, by replacing it with j=
ump table
> >using GCC's labels-as-values feature. The for loop condition check c=
an also be
> >removed, because the filter code always end with a RET instruction.
>=20
> With commit 01f2f3f6ef4d076c I reworked the BPF code so that gcc is i=
n the
> ability to generate a jump table, I double checked this. Not sure wha=
t happened
> in the meantime.
>=20

A switch() always generates one conditional branch, catching values not
enumerated in the "case ..." clauses.



