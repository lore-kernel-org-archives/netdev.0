From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fixed PHY Device Tree usage?
Date: Sat, 13 Jul 2013 01:29:39 +0200
Message-ID: <51E09163.8050206@openwrt.org>
References: <20130709183312.6c4d052d@skate> <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com> <1733937.SiPWt3mDlH@lenovo> <20130710182216.0dcfaaaf@skate> <CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com> <20130710183951.09a0bcea@skate> <CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com> <CACxGe6tzMhjH8nxJ1Ezrc43DqCmv-pWRW2NsXa=fP-6Fh_t5PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	=?ISO-8859-1?Q?Gregory_Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Andy Fleming <afleming@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:58591 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957Ab3GLX3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 19:29:46 -0400
Received: by mail-wg0-f46.google.com with SMTP id c11so8477989wgh.13
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 16:29:44 -0700 (PDT)
In-Reply-To: <CACxGe6tzMhjH8nxJ1Ezrc43DqCmv-pWRW2NsXa=fP-6Fh_t5PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/07/2013 00:44, Grant Likely a =E9crit :
> On Wed, Jul 10, 2013 at 6:23 PM, Florian Fainelli <florian@openwrt.or=
g> wrote:
>> Hello Thomas,
>>
>> 2013/7/10 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
>>> Dear Florian Fainelli,
>>>
>>> On Wed, 10 Jul 2013 17:29:44 +0100, Florian Fainelli wrote:
>> [snip]
>>
>>>
>>>>>                  };
>>>>>
>>>>>                  phy1: ethernet-phy@1 {
>>>>>                          ... all the properties you listed ...
>>>>>                          ... maybe the "id" property is not neede=
d
>>>>>                              because of the phandle ...
>>>>>                  };
>>>>>          };
>>>>>
>>>>>          soc {
>>>>>                  ethernet@0 {
>>>>>                          phy =3D <&phy0>;
>>>>>                          ...
>>>>>                  };
>>>>>
>>>>>                  ethernet@1 {
>>>>>                          phy =3D <&phy1>;
>>>>>                          ...
>>>>>                  };
>>>>>          };
>>>>>
>>>>> or do you have in mind another representation?
>>>>
>>>> Not really this is more or less what I had in mind. I am wondering
>>>> whether we should really declare the "mdio-fixed" node, or if we
>>>> should not rather make the following:
>>>>
>>>> - declare all PHY nodes in the system as sub nodes of their belong=
ing
>>>> real hardware MDIO bus node
>>>> - flag specific PHY nodes as "fixed" with a "fixed-link" boolean f=
or instance
>>>> - if we see that flag, make that specific PHY node bind to the
>>>> fixed-phy driver instead
>>>
>>> So the fixed PHY driver is going to travel through *all* nodes of t=
he
>>> DT, and whenever some random node has a "fixed" property, it's goin=
g to
>>> say it corresponds to a fixed PHY? That doesn't seem like a good id=
ea.
>>
>> Why not? Since we are already have to scan the entire MDIO bus we ar=
e
>> attached to, when we encounter such a PHY node with the special
>> "fixed" properties, we just call fixed_phy_add() with the right
>> parameters and voila. Which is also the reason why I was suggesting =
to
>> put the "fixed" PHY nodes as sub-nodes of the real MDIO node such th=
at
>> we have this logic only in one place.
>
> Hi Florian,
>
> I think this discussion is going in the wrong direction. The concept
> of a dummy phy is really a Linux kernel internal detail. Creating som=
e
> kind of dummy MDIO bus node does not describe the hardware. There is
> already support in the kernel for Ethernet MACs connected directly to
> a switch or other device. It is far better to describe how the MAC
> needs to be configured than to invent a non-existent phy. Search for
> "fixed-link" in the kernel tree to see how it is used.

Errm, fixed-link is deprecated according to the comment which parses it=
=2E=20
In fact, the code parsing this special property does not parse all the=20
integers representing the fixed-link. But fair enough, if that is the=20
way to go, then let's stick with it.
