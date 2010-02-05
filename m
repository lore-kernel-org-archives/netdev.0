From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net: emaclite: adding MDIO and phy lib support
Date: Fri, 5 Feb 2010 12:22:16 -0800
Message-ID: <fa686aa41002051222o4670a35alea373d45c3f7498d@mail.gmail.com>
References: <1265244560-23593-1-git-send-email-john.linn@xilinx.com>
	<a3cfa41e-7220-460d-8fce-96db4752ab08@SG2EHSMHS012.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	Sadanand Mutyala <sadanan@xilinx.com>
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f189.google.com ([209.85.211.189]:42087 "EHLO
	mail-yw0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257Ab0BEUWi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:22:38 -0500
Received: by ywh27 with SMTP id 27so3746623ywh.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2010 12:22:36 -0800 (PST)
In-Reply-To: <a3cfa41e-7220-460d-8fce-96db4752ab08@SG2EHSMHS012.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2010 at 10:50 AM, John Linn <John.Linn@xilinx.com> wrote=
:
>> -----Original Message-----
>> From: Grant Likely
>> Sent: Thurs, 4 Feb 2010 11:12:29 AM
>> To: John Linn
>> Subject: FW: [PATCH] net: emaclite: adding MDIO and phy lib support
>>
>> Hi John and Sadanand. =A0Looks like a good patch, but a few issues t=
o
>> resolve. =A0Comments below.
>>
>> g.
>
> Somehow I didn't get this message but found it out on the web, so thi=
s
> is a contrived version of the message so I could respond :)
>
>>
>> On Wed, Feb 3, 2010 at 5:49 PM, John Linn <john.linn@xxxxxxxxxx>
> wrote:
>> > These changes add MDIO and phy lib support to the driver as the
>> > IP core now supports the MDIO bus.
>> >
>> > The MDIO bus and phy are added as a child to the emaclite in the
> device
>> > tree as illustrated below.
>> >
>> > mdio {
>> > =A0 =A0 =A0 =A0#address-cells =3D <1>;
>> > =A0 =A0 =A0 =A0#size-cells =3D <0>;
>> > =A0 =A0 =A0 =A0phy0: phy@7 {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <7>;
>>
>> For completeness, phy node need a "compatible" property.
>
> It seems like this is in the device tree only but the driver won't us=
e
> it. So no real affect on the driver unless I'm not synced up with you=
=2E

That's right.  That's why I said "for completeness".  This is just an
example phy node, but it is good practice to give accurate examples.
:-)

>> > =A0 =A0 =A0 =A0/* Set the MAC address in the EmacLite device */
>> > - =A0 =A0 =A0 xemaclite_set_mac_address(lp, ndev->dev_addr);
>> > + =A0 =A0 =A0 xemaclite_update_address(lp, ndev->dev_addr);
>> > +
>> > + =A0 =A0 =A0 /* Check if MDIO is included in the HW */
>> > + =A0 =A0 =A0 lp->has_mdio =3D get_bool(ofdev, "xlnx,include-mdio"=
);
>> > + =A0 =A0 =A0 if (lp->has_mdio) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_node =3D of_parse_phandle(of=
dev->node,
> "phy-handle", 0);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D xemaclite_mdio_setup(lp, &ofd=
ev->dev);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rc)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(&ofdev->dev=
, "error registering
> MDIO bus\n");
>> > + =A0 =A0 =A0 }
>>
>> What if the phy is attached to a different MDIO bus (which is
>> completely possible)? =A0The fetching of phy_node should be performe=
d
>> regardless of whether or not xlnx,include-mdio is set.
>>
>
> So the issue here is that the IP core can be built without any PHY
> interface and MDIO bus.

Right, but just because the *core* doesn't have a phy interface built
in, doesn't mean that the PHY isn't attached to a different MDIO bus
(ie. on another emaclite, or on a gpio driven MDIO bus).  So even if
mdio is configured out, the driver should still handle the case of it
having an valid phy-handle.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
