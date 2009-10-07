From: vb@vsbe.com
Subject: Re: Nested function in drivers/of/of_mdio.c
Date: Wed, 7 Oct 2009 09:23:04 -0700
Message-ID: <f608b67d0910070923h54c30c2doae08550b0791ed1b@mail.gmail.com>
References: <200910071715.57249.jezz@sysmic.org> <fa686aa40910070911x769d7d41u908fbcf6b0980962@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linuxppc <linuxppc-dev@lists.ozlabs.org>,
	Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:58275 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759537AbZJGQYg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 12:24:36 -0400
Received: by vws41 with SMTP id 41so2710668vws.4
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 09:23:24 -0700 (PDT)
In-Reply-To: <fa686aa40910070911x769d7d41u908fbcf6b0980962@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys, are there other instances of nested C functions in the codebase
or was this the first attempt?


On Wed, Oct 7, 2009 at 9:11 AM, Grant Likely <grant.likely@secretlab.ca=
> wrote:
> On Wed, Oct 7, 2009 at 9:15 AM, J=E9r=F4me Pouiller <jezz@sysmic.org>=
 wrote:
>> Dear,
>>
>> I have a problem with commit 8bc487d150b939e69830c39322df4ee486efe38=
1
>> in file drivers/of/of_mdio.c in function of_phy_find_device.
>>
>> As you see, this function define match() as a nested function. My
>> compiler (powerpc-e500-linux-gnu-gcc-3.4.1) raise an error during li=
nk
>> due to this nested definition:
>> =A0drivers/built-in.o(.text+0x5e2a4): In function `of_phy_find_devic=
e': /home/jezz/linux-next/drivers/of/of_mdio.c:107:
>> undefined reference to `__trampoline_setup'
>>
>> I am sure I could solve problem by rebuilding my toolchain.
>> Nevertheless, I think nested function definition is not perfectly
>> supported by all compilers. Also, I suggest to place function match(=
)
>> outside of scope of of_phy_find_device as in following patch.
>
> I'm okay with that, but if you're moving code out of the file scope,
> then please rename the function to of_phy_match() to avoid global
> namespace conflicts.
>
> g.
>
>>
>> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
>> index bacaa53..c7b2e26 100644
>> --- a/drivers/of/of_mdio.c
>> +++ b/drivers/of/of_mdio.c
>> @@ -97,6 +97,10 @@ int of_mdiobus_register(struct mii_bus *mdio, str=
uct device_node *np)
>> =A0}
>> =A0EXPORT_SYMBOL(of_mdiobus_register);
>>
>> +static int match(struct device *dev, void *phy_np)
>> +{
>> + =A0 =A0 =A0 return dev_archdata_get_node(&dev->archdata) =3D=3D ph=
y_np;
>> +}
>> =A0/**
>> =A0* of_phy_find_device - Give a PHY node, find the phy_device
>> =A0* @phy_np: Pointer to the phy's device tree node
>> @@ -106,11 +110,6 @@ EXPORT_SYMBOL(of_mdiobus_register);
>> =A0struct phy_device *of_phy_find_device(struct device_node *phy_np)
>> =A0{
>> =A0 =A0 =A0 =A0struct device *d;
>> - =A0 =A0 =A0 int match(struct device *dev, void *phy_np)
>> - =A0 =A0 =A0 {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev_archdata_get_node(&dev->arc=
hdata) =3D=3D phy_np;
>> - =A0 =A0 =A0 }
>> -
>> =A0 =A0 =A0 =A0if (!phy_np)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>>
>>
>> What do you think about it?
>>
>> Best regards,
>>
>> --
>> J=E9r=F4me Pouiller (jezz AT sysmic DOT org)
>>
>
>
>
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
>
