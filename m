From: Leonardo Uzcudun <uzcudunl@yahoo.it>
Subject: Re: VLAN 1 - Native
Date: Thu, 2 Feb 2012 09:09:01 +0000 (GMT)
Message-ID: <1328173741.73927.YahooMailNeo@web29018.mail.ird.yahoo.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com> <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com> <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com> <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com> <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com> <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com> <4F2991FD.8090407@ziu.info>
Reply-To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yao zhao <yao.development@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm1-vm0.bullet.mail.ird.yahoo.com ([77.238.189.95]:42871 "HELO
	nm1-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751188Ab2BBJJE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 04:09:04 -0500
In-Reply-To: <4F2991FD.8090407@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Michal:

It is working on kernel 3.0.0-15 Ubuntu. I've just to modify the ebtabl=
es command as:
ebtables -t broute -A BROUTING -i eth0 -p 802_1Q --vlan-id 101 -j DROP =
(protocol is a must when you use --vlan-id)


I'll test it on kernel 2.6.32-5 Debian


Just last question,in the case i should implement this kind of configur=
ation in a kernel 2.6.31, should i backport/patch anything? is it a bad=
 idea (running it on 2.6.31)?

Thanks again.

BR,

Leo



----- Messaggio originale -----
Da: Michal Soltys <soltys@ziu.info>
A: Leonardo Uzcudun <uzcudunl@yahoo.it>
Cc: yao zhao <yao.development@gmail.com>; Eric Dumazet <eric.dumazet@gm=
ail.com>; "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Inviato: Mercoled=EC 1 Febbraio 2012 20:26
Oggetto: Re: VLAN 1 - Native

On 12-02-01 17:44, Leonardo Uzcudun wrote:
> I'm sorry guys but i'm not understanding. Allow me to ask in a differ=
ent way.
>
> I've a linux computer with 3 network cards (eth0, eth1 and eth2)
>
> eth0 is connected to a switch with vlans config.
> eth1 is connected to a network that has VID 1
> eth2 is connected to a network that has VID 101
>

Assuming you have:

eth0: 1u 101t
eth1: 1u
eth2: 101u

would this work for you ?:

ip link add link eth0 name eth0.101 type vlan id 101
ebtables -t broute -A BROUTING -i eth0 --vlan-id 101 -j DROP
brctl addbr br_vlan_1
brctl addbr br_vlan_101
brctl addif br_vlan_1 eth0 eth1
brctl addif br_vlan_101 eth0.101 eth2

ebtables should make 101 tagged traffic go through br_vlan_101 instead=20
of br_vlan_1

I think there's also option for doing it with single bridge interface=20
and some more complex ebtables rules, but the above if I didn't miss=20
anything, should work fine.
