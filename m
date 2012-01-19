From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route problem
Date: Thu, 19 Jan 2012 07:50:57 +0100
Message-ID: <1326955857.1113.17.camel@edumazet-laptop>
References: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com>
	 <1326878864.2316.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <B97B134FACB2024DB45F524AB0A7B7F2058B020A@XMB-BGL-419.cisco.com>
	 <1326881723.2316.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120118202909.8a3d6963.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Prashant Batra (prbatra)" <prbatra@cisco.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49159 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab2ASGvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 01:51:01 -0500
Received: by wics10 with SMTP id s10so115680wic.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 22:51:00 -0800 (PST)
In-Reply-To: <20120118202909.8a3d6963.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 20:29 -0500, Bill Fink a =C3=A9crit =
:
> On Wed, 18 Jan 2012, Eric Dumazet wrote:

> Actually, if I'm interpreting the "ip route list cache" output
> correctly, it appears it has local IP addresses of both 192.168.101.1=
0
> and 192.168.101.20.
>=20
> > local 192.168.101.10 from 192.168.101.101 dev lo  src 192.168.101.1=
0=20
> >     cache <local,src-direct>  iif eth1
>=20
> > local 192.168.101.20 from 192.168.101.101 dev lo  src 192.168.101.2=
0=20
> >     cache <local,src-direct>  iif eth1
>=20
> And since his gateway is 192.168.101.10, an apparently local
> IP address, that would probably explain the direct ARPS for
> 172.16.60.*.
>=20

Ah ok, thanks.

Pity that such a convoluted setup must be guessed instead of clearly
explained in the initial mail.

Prashant, this is netdev mailing list, with more than a thousand
subscribers, you should send mails with your detailed setup, this will
save time for everyone.

If not, people will flag you as "yet another lazy student trying to
understand how things work"


> [Prashant] So is this the correct behavior? What my original intentio=
n
> was to capture the packets from the=20
> interface acting as gateway. So with this behavior I will not be able
> to capture the packets as 172.16.60.* are not=20
> present on the local machine, and it will not get any ARP response.
> Consider the gateway on a different machine, in which case ARP reques=
t
> will go for gateway IP, and local machine will=20
> get the ARP response and send the packets to gateway.
>=20
With the setup you gave, you said : 172.16.60.0/24 addresses are
directly reachable on eth1 device, with source address 192.168.101.20

Why should the kernel send an ARP request for 192.168.101.20, since its
one of its own IP address ?

=46or localy generated packets, why this machine would act as a 'gatewa=
y'
at all ? A gateway should forward packets, and first step would be to
_receive_ a packet, not sending one !
