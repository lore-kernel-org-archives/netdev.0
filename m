From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Mon, 07 Nov 2011 17:55:05 +0100
Message-ID: <1320684905.2361.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111107162117.5330236221@apps0.cs.toronto.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Siebenmann <cks@cs.toronto.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46985 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755119Ab1KGQzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 11:55:09 -0500
Received: by bke11 with SMTP id 11so3778025bke.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 08:55:08 -0800 (PST)
In-Reply-To: <20111107162117.5330236221@apps0.cs.toronto.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 novembre 2011 =C3=A0 11:21 -0500, Chris Siebenmann a =C3=A9=
crit :
> I have a weird problem where a GRE tunnel periodically won't transmit
> some (TCP) packets, while at the same time it will transmit others ju=
st
> fine. This is happening in the current kernel.org git head kernel as
> well as earlier ones.
>=20
>  The networking environment is a GRE tunnel over IPSec in tunnel mode
> ('esp/tunnel/...') over a DSL PPPoE link. What I observe is that
> periodically outbound SSH connections stall early in the protocol
> negociation, and other TCP connections can similarly stall. Sometimes
> they recover and sometimes they time out. The problem is pretty
> reproducable and regular, although not constant (sometimes the affect=
ed
> packets get through right away).
>=20
>  I have tcpdump'd both the GRE tunnel device and the underlying DSL
> PPPoE device and during a stall, the GRE tcpdump will show packets be=
ing
> sent that do not appear on the DSL PPPoE link. All of the packets tha=
t
> I've seen stalling have had 500 data octets.
>=20
> Typical packets are:
> 	IP 128.100.3.52.52063 > 128.100.3.51.ssh: Flags [.], seq 22:522, ack=
 22, win 91, options [nop,nop,TS val 143020 ecr 966040433], length 500
>=20
> (here 128.100.3.52 is the GRE tunnel IP address of the machine
> experiencing problems)
>=20
> or ttcp:
> 	IP 128.100.3.52.46585 > 128.100.3.51.5001: Flags [.], seq 1:501, ack=
 1, win 91, options [nop,nop,TS val 729200 ecr 979199256], length 500
>=20
> Ttcp had a whole run of 'length 500' packets fail to go through. SSH
> will actually successfully transmit later (different-length) packets,
> eg:
> 	128.100.3.52.52063 > 128.100.3.51.ssh: Flags [P.], seq 522:926, ack =
22, win 91, options [nop,nop,TS val 143037 ecr 966040450], length 404
>=20
>  The DSL PPPoE link has an MTU of 1492 and the GRE tunnel has an MTU =
of
> 1200 (on both ends). As far as I can tell they do pass packets of thi=
s
> size. *However*, on kernels that display this problem tracepath and '=
ip
> route show table cache' both report that the GRE tunnel has a path MT=
U
> of 854 going from 128.100.3.52 to 128.100.3.51; however, 128.100.3.51
> sees a pmtu of 1200 for the path to 128.100.3.52.
>=20
>  The machine experiencing these problems is a 64-bit x86_64 Fedora 15
> machine with various kernels. The problem does not happen with the
> current Fedora 14 kernel (nominally 2.6.35.14); it does happen with t=
he
> Fedora 15 kernel ('2.6.40.6' aka some version of 3.0.0), the Fedora 1=
6
> kernel (some version of 3.1.0) and on the current kernel.org git head
> as of last night. I am not running NetworkManager; all networking is
> statically configured and not changing during operation, and my IPSec
> setup is statically keyed[*].
>=20
>  I would be happy to run any debugging tests or give any further
> information that people want. Should I try a different kernel git
> repo than Linus's kernel.org one?
>=20
>  Thanks in advance.
>=20
> (While I'm reading the mailing list I'm not directly subscribed to it=
,
> so copying me on replies will make sure that I see them immediately.)
>=20

Do you have any errors on :

ip -s -d link show dev greXXXX
