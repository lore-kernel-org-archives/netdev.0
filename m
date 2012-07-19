From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 19:07:47 +0200
Message-ID: <1342717667.2626.4494.camel@edumazet-glaptop>
References: <1342688332.2626.4001.camel@edumazet-glaptop>
	 <20120719.083544.1223522161508413373.davem@davemloft.net>
	 <20120719.084503.136853790544876708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:64368 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab2GSRHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:07:54 -0400
Received: by vcbfk26 with SMTP id fk26so2179395vcb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:07:53 -0700 (PDT)
In-Reply-To: <20120719.084503.136853790544876708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 08:45 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 19 Jul 2012 08:35:44 -0700 (PDT)
>=20
> > Looks great, applied, thanks Eric.
>=20
> I take that back, it doesn't build:
>=20
> net/ipv4/ip_output.c: In function =E2=80=98ip_send_unicast_reply=E2=80=
=99:
> net/ipv4/ip_output.c:1481:1: error: section attribute cannot be speci=
fied for local variables
> net/ipv4/ip_output.c:1481:1: error: section attribute cannot be speci=
fied for local variables
> net/ipv4/ip_output.c:1481:1: error: declaration of =E2=80=98__pcpu_un=
ique_unicast_sock=E2=80=99 with no linkage follows extern declaration
> net/ipv4/ip_output.c:1481:1: note: previous declaration of =E2=80=98_=
_pcpu_unique_unicast_sock=E2=80=99 was here
> net/ipv4/ip_output.c:1481:9: error: section attribute cannot be speci=
fied for local variables
> net/ipv4/ip_output.c:1481:9: error: weak declaration of =E2=80=98unic=
ast_sock=E2=80=99 must be public

Strange, it builds on my machines, and I got nice performance boost.

Apparently your arch doesnt handle the=20

static DEFINE_PER_CPU(struct inet_sock, unicast_sock)

in the function body ?
