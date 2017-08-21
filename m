From: icenowy-h8G6r0blFSE@public.gmane.org
Subject: Re: Re: [PATCH 2/4] dt-bindings: add binding for
 RTL8211E Ethernet PHY
Date: Mon, 21 Aug 2017 22:53:24 +0800
Message-ID: <19ad1316a74e344d3e1c783458eb4d59@aosc.io>
References: <20170421232436.10924-1-icenowy@aosc.io>
 <20170421232436.10924-3-icenowy@aosc.io>
 <c7aa9d7a-5e97-0e7f-2b1c-584a4de00837@gmail.com>
 <edf26d7de605a93bfce258de0353df6d@aosc.io>
 <a455c822-d5aa-3f66-03c5-4d1268f9104b@gmail.com>
 <D714E47B-D6B2-4C9F-B9D7-FB9D170E0ADF@aosc.io>
 <068f1323-3864-620c-0deb-6c5e04a9e498@gmail.com>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBZ7H5PGAKGQEPT5C7WA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <068f1323-3864-620c-0deb-6c5e04a9e498-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

=E5=9C=A8 2017-05-05 02:29=EF=BC=8CFlorian Fainelli =E5=86=99=E9=81=93=EF=
=BC=9A
> On 05/04/2017 11:26 AM, Icenowy Zheng wrote:
>>=20
>>=20
>> =E4=BA=8E 2017=E5=B9=B45=E6=9C=885=E6=97=A5 GMT+08:00 =E4=B8=8A=E5=8D=88=
2:21:29, Florian Fainelli=20
>> <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =E5=86=99=E5=88=B0:
>>> On 05/04/2017 11:10 AM, icenowy-h8G6r0blFSE@public.gmane.org wrote:
>>>> =E5=9C=A8 2017-04-22 08:22=EF=BC=8CFlorian Fainelli =E5=86=99=E9=81=93=
=EF=BC=9A
>>>>> On 04/21/2017 04:24 PM, Icenowy Zheng wrote:
>>>>>> From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>>>>>=20
>>>>>> Some RTL8211E Ethernet PHY have an issue that needs a workaround
>>>>>> indicated with device tree.
>>>>>>=20
>>>>>> Add the binding for a property that indicates this workaround.
>>>>>>=20
>>>>>> Signed-off-by: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>>>>> ---
>>>>>>  .../devicetree/bindings/net/realtek,rtl8211e.txt   | 22
>>>>>> ++++++++++++++++++++++
>>>>>>  1 file changed, 22 insertions(+)
>>>>>>  create mode 100644
>>>>>> Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>>=20
>>>>>> diff --git
>>>>>> a/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>> b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>> new file mode 100644
>>>>>> index 000000000000..c1913301bfe8
>>>>>> --- /dev/null
>>>>>> +++ b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>> @@ -0,0 +1,22 @@
>>>>>> +Realtek RTL8211E Ethernet PHY
>>>>>> +
>>>>>> +One batch of RTL8211E is slight broken, that needs some special
>>> (and
>>>>>> +full of magic numbers) tweaking in order to make GbE to operate
>>>>>> properly.
>>>>>> +The only well-known board that used the broken batch is Pine64+.
>>>>>> +Configure it through an Ethernet OF device node.
>>>>>> +
>>>>>> +Optional properties:
>>>>>> +
>>>>>> +- realtek,disable-rx-delay:
>>>>>> +  If set, RX delay will be completely disabled (according to
>>>>>> Realtek). This
>>>>>> +  will affect the performance on non-broken boards.
>>>>>> +  default: do not disable RX delay.
>>>>>=20
>>>>> Please don't introduce custom properties to do that, instead=20
>>>>> correct
>>>>> specify the "phy-mode" such that it is e.g: "rgmii-txid" which
>>> indicates
>>>>> that there should be no RX internal delay, but a TX internal delay
>>> added
>>>>> by the PHY.
>>>>=20
>>>> Checked the document, the meaning of "rgmii-txid" is not correct
>>> here.
>>>>=20
>>>> This doesn't effect the MAC, and the MAC should still add TX delay.
>>>>=20
>>>> The definition of "rgmii-txid" in
>>>> Documentation/devicetree/binding/net/ethernet.txt is "RGMII with
>>>> internal TX delay provided by the PHY, the MAC should not add an TX
>>> delay
>>>> in this case". However, this do not indicate that the MAC doesn't=20
>>>> add
>>> TX
>>>> delay; in fact that just totally disabled the PHY to provide the RX
>>> delay.
>>>> MAC still should to add delay on both TX/RX, which is the semantic=20
>>>> of
>>>> standard "rgmii".
>>>>=20
>>>> So I cannot used "rgmii-txid" here, but should continue to use this
>>>> custom property.

Sorry for replying an old email, but it's because the driver of the MAC=20
I
used is merged (dwmac-sun8i).

The driver of the MAC currently only supports "mii", "rmii", and=20
"rgmii",
and according to the SoC's user manual, the MAC cannot has its delays
disabled.

How should it handle this "rgmii-txid" here? Just treat it as "rgmii"?

>>>=20
>>> This is absolutely not a correct understanding. The 'phy-mode'=20
>>> property
>>> defines the contract between the MAC and PHY. It is defined from the
>>> PHY's perspective of the delay, which means that the MAC has to=20
>>> either
>>> also provide an adequate delay (RX or TX) or not (RX or TX). So if=20
>>> you
>>> specified 'phy-mode' =3D "rgmii" this means that the MAC needs to adds
>>> the
>>> TX and RX delay, so implcitly this means that your MAC operates in
>>=20
>> The MAC doesn't lose its responsibility to tweak RX/TX delays with=20
>> this property set.
>=20
> No it does not but now there is no contract binding the MAC and the PHY
> together was to what an appropriate delay configuration there should=20
> be.
> This is why using phydev->interface (directly inherited from=20
> 'phy-mode')
> is important because it binds the PHY and MAC on a contract.
>=20
>>=20
>> This situation is that, the PHY's RX delay tweaking function is=20
>> broken. But it doesn't mean that the PHY can take over *all*=20
>> responsibility to tweak TX, it still needs MAC to tweak TX.
>=20
> Correct, so what part of my answer was not clear in that sense?
>=20
>>=20
>>> "rgmii-id", if the property was defined from the perspective of the
>>> MAC,
>>> which it is not.
>>>=20
>>> Both the Ethernet PHY driver and the MAC driver need to take care of
>>> adjusting the delays based on the phydev->interface value.
>>>=20
>>> The property you are introducing here is absolutely not appropriate
>>> because it is entirely redundant with what 'phy-mode' already=20
>>> defines,
>>> except the latter also covers a lot more cases.

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
