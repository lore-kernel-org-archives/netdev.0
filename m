From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH] mvneta: implement SGMII-based in-band link state signaling
Date: Fri, 03 Apr 2015 13:00:28 +0300
Message-ID: <551E64BC.6080203@list.ru>
References: <551AA02B.2050104@list.ru> <20150402.205131.1699226515102250937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, f.fainelli@gmail.com,
	Stas Sergeev <stsp@users.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150402.205131.1699226515102250937.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

03.04.2015 03:51, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Stas Sergeev <stsp@list.ru>
> Date: Tue, 31 Mar 2015 16:24:59 +0300
>=20
>> @@ -2590,6 +2651,7 @@ static int mvneta_mdio_probe(struct mvneta_por=
t *pp)
>>
>>  static void mvneta_mdio_remove(struct mvneta_port *pp)
>>  {
>> +	fixed_phy_set_link_update(pp->phy_dev, NULL);
>=20
> I do not see any other driver doing this on shutdown.
> Please show me why it is necessary.
Hello David, sorry for this being discussed in a different thread,
so here you have a few pointers to why is this needed:
https://lkml.org/lkml/2015/3/30/367

> And if it is, all other drivers registering a fixed phy link update
> function need to be adjusted to do the same thing.
Or, for example, get rid of the callback and add an API:
http://www.spinics.net/lists/netdev/msg323517.html

Then you get the patch that avoids all this call-back singing and danci=
ng:
http://www.spinics.net/lists/netdev/msg323518.html

In any case, I posted 3 different implementations and hope
people will choose the best one (any choice is fine with me).
