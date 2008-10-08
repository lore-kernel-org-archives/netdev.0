From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Wed, 08 Oct 2008 11:45:27 -0700 (PDT)
Message-ID: <20081008.114527.189056050.davem@davemloft.net>
References: <20081007160729.60c076c4@speedy>
	<20081007.135548.56141000.davem@davemloft.net>
	<48ECBBD8.9060602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753087AbYJHSpw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 14:45:52 -0400
In-Reply-To: <48ECBBD8.9060602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 08 Oct 2008 15:55:36 +0200

> David Miller a =E9crit :
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Tue, 7 Oct 2008 16:07:29 +0200
> >=20
> >> The idea of keeping chains short is the problem. That code should
> >> just be pulled because it doesn't help that much, and also creates
> >> bias on the port randomization.
> > I have that patch from Vitaly Mayatskikh which does exactly this.
> > I keep looking at it, but I can't bring myself to apply it since
> > I'm not completely convinced.
>=20
> Vitaly patch might be appropriate if only few UDP ports are opened.
>=20
> We could zap the code to search short chains and extend Vitaly's
> idea with following patch :

I really like this, and I've applied it to net-next-2.6

I think the "increment until back in range" do/while loop can
be improved a bit.  It can spin for more than 60,000 iterations
in some edge case scenerios as-is :-)

Ugh, there's also that expensive divide in there for the modulus.
