From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 3/3] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Sat, 24 Oct 2015 16:45:48 +0100
Message-ID: <yw1x611wfexf.fsf@unicorn.mansr.com>
References: <1445522558-5808-1-git-send-email-mans@mansr.com>
	<1445522558-5808-3-git-send-email-mans@mansr.com>
	<56297FF9.4070801@gmail.com> <yw1xa8r9fw6y.fsf@unicorn.mansr.com>
	<562A7000.2080502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562A7000.2080502@gmail.com> (Florian Fainelli's message of "Fri,
	23 Oct 2015 10:36:00 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46lorian Fainelli <f.fainelli@gmail.com> writes:

>>>> +static void nb8800_set_rx_mode(struct net_device *dev)
>>>> +{
>>>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>>>> +	struct netdev_hw_addr *ha;
>>>> +	int af_en;
>>>> +
>>>> +	if ((dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) ||
>>>> +	    netdev_mc_count(dev) > 64)
>>>
>>> 64, that's pretty generous for a perfect match filter, nice.
>>=20
>> That's bogus; I forgot to delete it.  The hardware uses a 64-entry h=
ash
>> table, and whoever wrote the old driver apparently didn't understand=
 how
>> it works.
>
> Might be best to put the interface in promiscuous mode until you have
> proper multicast support. Since this is for a Set-Top box chip, havin=
g
> proper multicast support still seems like something highly desirable.

The code below should work correctly with any number of multicast
addresses.

>>>> +	phydev =3D phy_find_first(bus);
>>>> +	if (!phydev || phy_read(phydev, MII_BMSR) <=3D 0) {
>>>
>>> What is this additional MII_MBSR read used for?
>>=20
>> On one of my boards, phylib misdetects a phy on the second ethernet =
port
>> even though there is none.  Perhaps I should revisit that problem an=
d
>> look for a better solution.
>
> I think that would be best, if you are currently using the Generic PH=
Y
> driver, consider writing a specific driver which would take care of
> quirky behavior.

The problem is that there is no PHY, yet for some reason reading the ID
registers appears to succeed.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
