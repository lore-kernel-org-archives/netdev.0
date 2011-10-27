From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Thu, 27 Oct 2011 12:24:32 +0200
Message-ID: <1319711072.2601.18.camel@edumazet-laptop>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:63154 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab1J0KYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 06:24:37 -0400
Received: by pzk36 with SMTP id 36so7058075pzk.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 03:24:37 -0700 (PDT)
In-Reply-To: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 octobre 2011 =C3=A0 19:25 -0700, Andy Lutomirski a =C3=A9cr=
it :
> When talking to an unfixable interactive peer that fails to set
> TCP_NODELAY, disabling delayed ACKs can help mitigate the problem.
> This is an evil thing to do, but if the entire network is private,
> it's not that evil.
>=20
> This works around a problem with the remote *application*, so make
> it a socket option instead of a sysctl or a per-route option.
>=20
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
>=20
> This patch is a bit embarrassing.  We talk to remote applications ove=
r
> TCP that are very much interactive but don't set TCP_NODELAY.  These
> applications apparently cannot be fixed.  As a partial workaround, if=
 we
> ACK every incoming segment, then as long as they don't transmit two
> segments per rtt, we do pretty well.
>=20
> Windows can do something similar, but it's per interface instead of p=
er
> socket:
>=20
> http://support.microsoft.com/kb/328890

Hi Andy

Yet another delayed ack hacking proposal :)

Well, to be honest, I find the MS Windows tunable more generic.
[ But doing it for a whole interface is wrong, it should be per socket
to allow best tuning ]

Setting the value to 4 (instead of default 2) for example would _reduce=
_
number of ACK packets in bulk transferts [ We can do that if GRO is on,
as a side effect ]

Also the 40ms/200ms values (TCP_DELACK_{MIN|MAX}) could be tunables.
(system or per socket)
RFC 1122 says it SHOULD be less than 500ms. The time criteria is IMHO
far more palatable for an application author than "number of delayed
acks"
