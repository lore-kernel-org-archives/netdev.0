From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Wed, 1 Jul 2009 05:50:18 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0907010535170.6438@fbirervta.pbzchgretzou.qr>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr> <20090701011528.GA28676@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:48601 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbZGADuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 23:50:17 -0400
In-Reply-To: <20090701011528.GA28676@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2009-07-01 03:15, Herbert Xu wrote:
>On Tue, Jun 30, 2009 at 10:16:35PM +0200, Jan Engelhardt wrote:
>>
>> It makes sense absolutely. Consider:
>>=20
>> * packet enters bridge
>> * NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfil=
ter.c
>> * (connection tracking entry is set up)
>> * let bridging decision be "local delivery"
>
>No, my question is does it ever make sense to use conntrack as
>part of bridge netfilter.  That is, do you ever want to test it
>in your rules that are run as part of bridge netfilter.

There is the possibility that some users have -m conntrack in their
mangle table in the PREROUTING chain. However, I am pretty sure that
if there are such users, they do it because of the layer-3/4/5/7 part
and not care about bridge so much.

>conntrack is inherently a security hole when used as part of
>bridging, because it ignores the Ethernet header so two unrelated
>connections can be tracked as one.

On secondary thought, one could also argue that because conntrack=20
ignores the interface, two unrelated connections happening to be routed=
=20
through the same machine(*) are tracked as one, too.




(*)
ip rule iif eth0 table 7
ip rule iif eth1 table 7
ip rule iif eth2 table 8
ip rule iif eth3 table 8
ip route add 2003::1/128 dev eth0 table 7
ip route add 2003::2/128 dev eth1 table 7
ip route add 2003::1/128 dev eth2 table 8
ip route add 2003::2/128 dev eth3 table 8
(four single nets, four single hosts)
In Unicode:

    A
    0
  =E2=94=8C=E2=94=80=E2=95=91=E2=94=80=E2=94=80=E2=94=80=E2=94=90
B1=E2=95=90=E2=95=90=E2=95=9D   =E2=94=82
  =E2=94=82   =E2=95=94=E2=95=90=E2=95=902C
  =E2=94=94=E2=94=80=E2=94=80=E2=94=80=E2=95=91=E2=94=80=E2=94=98
      3
      D
