From: icenowy-h8G6r0blFSE@public.gmane.org
Subject: Re: [PATCH 2/4] dt-bindings: add binding for RTL8211E
 Ethernet PHY
Date: Sat, 22 Apr 2017 09:12:04 +0800
Message-ID: <fbb8f58b7a0d470bc69ae2ef38090186@aosc.io>
References: <20170421232436.10924-1-icenowy@aosc.io>
 <20170421232436.10924-3-icenowy@aosc.io>
 <c7aa9d7a-5e97-0e7f-2b1c-584a4de00837@gmail.com>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBZW35LDQKGQENCNNQIA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <c7aa9d7a-5e97-0e7f-2b1c-584a4de00837-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

=E5=9C=A8 2017-04-22 08:22=EF=BC=8CFlorian Fainelli =E5=86=99=E9=81=93=EF=
=BC=9A
> On 04/21/2017 04:24 PM, Icenowy Zheng wrote:
>> From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>=20
>> Some RTL8211E Ethernet PHY have an issue that needs a workaround
>> indicated with device tree.
>>=20
>> Add the binding for a property that indicates this workaround.
>>=20
>> Signed-off-by: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>> ---
>>  .../devicetree/bindings/net/realtek,rtl8211e.txt   | 22=20
>> ++++++++++++++++++++++
>>  1 file changed, 22 insertions(+)
>>  create mode 100644=20
>> Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>=20
>> diff --git=20
>> a/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt=20
>> b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>> new file mode 100644
>> index 000000000000..c1913301bfe8
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>> @@ -0,0 +1,22 @@
>> +Realtek RTL8211E Ethernet PHY
>> +
>> +One batch of RTL8211E is slight broken, that needs some special (and
>> +full of magic numbers) tweaking in order to make GbE to operate=20
>> properly.
>> +The only well-known board that used the broken batch is Pine64+.
>> +Configure it through an Ethernet OF device node.
>> +
>> +Optional properties:
>> +
>> +- realtek,disable-rx-delay:
>> +  If set, RX delay will be completely disabled (according to=20
>> Realtek). This
>> +  will affect the performance on non-broken boards.
>> +  default: do not disable RX delay.
>=20
> Please don't introduce custom properties to do that, instead correct
> specify the "phy-mode" such that it is e.g: "rgmii-txid" which=20
> indicates
> that there should be no RX internal delay, but a TX internal delay=20
> added
> by the PHY.

According to Realtek and Pine64 people, set that register is equal to
hardwire RDDLY line to low.

Is it the standard definition of RGMII-TXID?

(P.S. as it's only provided as a workaround, there's no implementation
known for RGMII-RXID and RGMII-ID)

Thanks,
Icenowy

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
