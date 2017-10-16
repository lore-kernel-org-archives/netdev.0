From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII bus
Date: Mon, 16 Oct 2017 07:16:14 -0700
Message-ID: <94DA9CFF-71F3-4D89-A2F2-342A69AB434E@gmail.com>
References: <20171016104525.26810-1-mnhu@prevas.dk> <20171016123233.GD4255@lunn.ch> <02997de6-1c8a-d69b-d19b-3a811288e8ed@prevas.dk> <20171016133943.GA7802@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>,
        =?ISO-8859-1?Q?Martin_Hundeb=F8ll?= <mnhu@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:53167 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751776AbdJPOQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:16:20 -0400
Received: by mail-oi0-f54.google.com with SMTP id c202so25166896oih.9
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:16:20 -0700 (PDT)
In-Reply-To: <20171016133943.GA7802@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 16, 2017 6:39:43 AM PDT, Andrew Lunn <andrew@lunn=2Ech> wrote:
>On Mon, Oct 16, 2017 at 03:16:51PM +0200, Martin Hundeb=C3=B8ll wrote:
>> On 2017-10-16 14:32, Andrew Lunn wrote:
>> >So this used to work=2E I have a 10G phy connected to the external MII
>> >bus on a 6390=2E I wonder when this got broken? Supporting phy-handle
>is
>> >old code, so when i added the external MII i don't think i needed to
>> >change any generic code=2E
>>=20
>> It could look like commit cd28a1a9baee7 ('net: dsa: fully divert PHY
>> reads/writes if requested') changed the of-case to use the mdio bus
>> associated with struct dsa_switch unconditionally=2E
>
>Hi Martin
>
>I think ds->phys_mii_mask is playing a role here=2E I need to add some
>debug prints to my setup and see what is happening with my external
>10G PHY=2E

FWIW, bcm_sf2 uses a mixture of PHYs referenced by phandle and fixed PHY s=
o if this did not work, I would have noticed=2E

The logic goes like this:

- try to connect to the PHY via phy-handle
- if we have a PHY we are connecting via phy-handle but we need to divert =
MDIO reads/writes connect using its address on the diverted bus
- connect using a fixed PHY
- finally try using the DSA slave MII bus which would connect to the switc=
h internal PHYs

If 1) fails then that needs investigating as it really should not=2E Is it=
 somehow possible that your PHY is powered down or something at that time a=
nd there is a timing/dependency not well handled?

--=20
Florian
