From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: Device tree property names for MDIO bus multiplexer. Was: Re:
	[PATCH 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Wed, 14 Sep 2011 18:41:21 -0600
Message-ID: <CACxGe6ubxrd=UL7WVgO2ZcgyLfyKdpHG=+MMgGT5G_TKvaaGUg@mail.gmail.com>
References: <1314820906-14004-1-git-send-email-david.daney@cavium.com>
	<1314820906-14004-3-git-send-email-david.daney@cavium.com>
	<129FAAB3-C9AD-43F6-A8CB-96548A47C4DC@kernel.crashing.org>
	<4E6FE5F9.2060604@cavium.com>
	<678076BE-4CF8-4AC9-BE9B-9AF1A17B7AF8@kernel.crashing.org>
	<4E711F59.6000801@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7977552771947630206=="
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4E711F59.6000801-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============7977552771947630206==
Content-Type: multipart/alternative; boundary=20cf307d0050b1886104acf022bc

--20cf307d0050b1886104acf022bc
Content-Type: text/plain; charset=ISO-8859-1

On Sep 14, 2011 3:40 PM, "David Daney" <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org> wrote:
>
> Well, I would really like to get an official maintainer's take on the name
of the parent MDIO bus property.  Prehaps Grant or Rob could opine on the
matter.
>
> Sooner would be better than later as I am about to start shipping boards
with this burnt into the bootloader.  If it needs changing, I could do it in
the next couple of days, but after that it escapes into the wild.

Considering that the parent bus should be either implicit in the node
topology, or if not then part of something like an i2c controlled bus
multiplexer, I don't think this is even remotely a big deal. Each bus
multiplexer will still likely have it's own binding, and therefore her to
make its own decision.

That said, in the interest of commonality, I think mdio-parent-bus would be
just fine.  parent-bus is probably too generic.

g.

>
> Thanks in advance,
> David Daney
>
>
> On 09/14/2011 01:42 PM, Kumar Gala wrote:
>>
>>
>> On Sep 13, 2011, at 6:23 PM, David Daney wrote:
>>
>>> On 09/13/2011 04:07 PM, Kumar Gala wrote:
>>>>
>>>>
>>>>> diff --git a/Documentation/devicetree/bindings/net/mdio-mux.txt
b/Documentation/devicetree/bindings/net/mdio-mux.txt
>>>>> new file mode 100644
>>>>> index 0000000..a908312
>>>>> --- /dev/null
>>>>> +++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
>>>>> @@ -0,0 +1,132 @@
>>>>> +Common MDIO bus multiplexer/switch properties.
>>>>> +
>>>>> +An MDIO bus multiplexer/switch will have several child busses that
are
>>>>> +numbered uniquely in a device dependent manner.  The nodes for an
MDIO
>>>>> +bus multiplexer/switch will have one child node for each child bus.
>>>>> +
>>>>> +Required properties:
>>>>> +- parent-bus : phandle to the parent MDIO bus.
>>>>
>>>>
>>>> Should probably be mdio-parent-bus
>>>
>>>
>>> Why?  We know it is MDIO.
>>>
>>> Serial bus multiplexing is not a concept limited to MDIO.  We would want
to use "parent-bus" for some I2C multiplexers as well.
>>
>>
>>> From many years of dealing with device trees.  We typically don't name
things overlay generically unless they will be used over and over again as a
common idiom (like reg, interrupt, etc.).
>>
>>
>> We don't really use 'bus' generically today.
>>
>>>
>>>>
>>>>> +
>>>>> +Optional properties:
>>>>> +- Other properties specific to the multiplexer/switch hardware.
>>>>> +
>>>>> +Required properties for child nodes:
>>>>> +- #address-cells =<1>;
>>>>> +- #size-cells =<0>;
>>>>> +- cell-index : The sub-bus number.
>>>>
>>>>
>>>> What does sub-bus number mean?
>>>
>>>
>>> There are N child buses (or sub-buses) coming out of the multiplexer.
The cell-index is used as a handle or identifier for each of these.
>>>
>>> The concrete example in Patch 3/3 is a multiplexer with four child
buses.  The happen to have cell-indexes of 0, 1, 2 and 3.
>>>
>>> In the GPIO case of patch 3/3, these directly correspond the the state
of the two GPIO pins controlling the multiplexer.  The driver then uses the
cell-index property to determine the state of the GPIO to connect any given
child.
>>>
>>> It is possible that the documentation part of the patch could be made
more clear about this.
>>>
>>>>
>>>>> +
>>>>> +
>>>>> +Example :
>>>>
>>>>
>>> [...]
>>>>>
>>>>> +
>>>>> +int mdio_mux_probe(struct platform_device *pdev,
>>>>> +                  int (*switch_fn)(int cur, int desired, void *data),
>>>>> +                  void *data)
>>>>> +{
>>>>> +       struct device_node *parent_bus_node;
>>>>> +       struct device_node *child_bus_node;
>>>>> +       int r, n, ret_val;
>>>>> +       struct mii_bus *parent_bus;
>>>>> +       struct mdio_mux_parent_bus *pb;
>>>>> +       struct mdio_mux_child_bus *cb;
>>>>> +
>>>>> +       if (!pdev->dev.of_node)
>>>>> +               return -ENODEV;
>>>>> +
>>>>> +       parent_bus_node = of_parse_phandle(pdev->dev.of_node,
"parent-bus", 0);
>>>>> +
>>>>> +       if (!parent_bus_node)
>>>>> +               return -ENODEV;
>>>>> +
>>>>> +       parent_bus = of_mdio_find_bus(parent_bus_node);
>>>>
>>>>
>>>>
>>>> So what happens if the parent bus probe happens after the mux probe?
>>>>
>>>
>>> The whole house of cards collapses.
>>>
>>> Grant Likely has a patch to deal with this by retrying the probing,  but
as far as I know, it has not been merged yet.
>>
>>
>> - k--
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>

--20cf307d0050b1886104acf022bc
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p><br>
On Sep 14, 2011 3:40 PM, &quot;David Daney&quot; &lt;<a href=3D"mailto:davi=
d.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org">david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org</a>&gt; wrote:<br>
&gt;<br>
&gt; Well, I would really like to get an official maintainer&#39;s take on =
the name of the parent MDIO bus property. =A0Prehaps Grant or Rob could opi=
ne on the matter.<br>
&gt;<br>
&gt; Sooner would be better than later as I am about to start shipping boar=
ds with this burnt into the bootloader. =A0If it needs changing, I could do=
 it in the next couple of days, but after that it escapes into the wild.</p=
>

<p>Considering that the parent bus should be either implicit in the node to=
pology, or if not then part of something like an i2c controlled bus multipl=
exer, I don&#39;t think this is even remotely a big deal. Each bus multiple=
xer will still likely have it&#39;s own binding, and therefore her to make =
its own decision.</p>

<p>That said, in the interest of commonality, I think mdio-parent-bus would=
 be just fine.=A0 parent-bus is probably too generic.</p>
<p>g.</p>
<p>&gt;<br>
&gt; Thanks in advance,<br>
&gt; David Daney<br>
&gt;<br>
&gt;<br>
&gt; On 09/14/2011 01:42 PM, Kumar Gala wrote:<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt; On Sep 13, 2011, at 6:23 PM, David Daney wrote:<br>
&gt;&gt;<br>
&gt;&gt;&gt; On 09/13/2011 04:07 PM, Kumar Gala wrote:<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;&gt; diff --git a/Documentation/devicetree/bindings/net/mdi=
o-mux.txt b/Documentation/devicetree/bindings/net/mdio-mux.txt<br>
&gt;&gt;&gt;&gt;&gt; new file mode 100644<br>
&gt;&gt;&gt;&gt;&gt; index 0000000..a908312<br>
&gt;&gt;&gt;&gt;&gt; --- /dev/null<br>
&gt;&gt;&gt;&gt;&gt; +++ b/Documentation/devicetree/bindings/net/mdio-mux.t=
xt<br>
&gt;&gt;&gt;&gt;&gt; @@ -0,0 +1,132 @@<br>
&gt;&gt;&gt;&gt;&gt; +Common MDIO bus multiplexer/switch properties.<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +An MDIO bus multiplexer/switch will have several chil=
d busses that are<br>
&gt;&gt;&gt;&gt;&gt; +numbered uniquely in a device dependent manner. =A0Th=
e nodes for an MDIO<br>
&gt;&gt;&gt;&gt;&gt; +bus multiplexer/switch will have one child node for e=
ach child bus.<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +Required properties:<br>
&gt;&gt;&gt;&gt;&gt; +- parent-bus : phandle to the parent MDIO bus.<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; Should probably be mdio-parent-bus<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Why? =A0We know it is MDIO.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Serial bus multiplexing is not a concept limited to MDIO. =A0W=
e would want to use &quot;parent-bus&quot; for some I2C multiplexers as wel=
l.<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt;&gt; From many years of dealing with device trees. =A0We typically =
don&#39;t name things overlay generically unless they will be used over and=
 over again as a common idiom (like reg, interrupt, etc.).<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt; We don&#39;t really use &#39;bus&#39; generically today.<br>
&gt;&gt;<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +Optional properties:<br>
&gt;&gt;&gt;&gt;&gt; +- Other properties specific to the multiplexer/switch=
 hardware.<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +Required properties for child nodes:<br>
&gt;&gt;&gt;&gt;&gt; +- #address-cells =3D&lt;1&gt;;<br>
&gt;&gt;&gt;&gt;&gt; +- #size-cells =3D&lt;0&gt;;<br>
&gt;&gt;&gt;&gt;&gt; +- cell-index : The sub-bus number.<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; What does sub-bus number mean?<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; There are N child buses (or sub-buses) coming out of the multi=
plexer. The cell-index is used as a handle or identifier for each of these.=
<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; The concrete example in Patch 3/3 is a multiplexer with four c=
hild buses. =A0The happen to have cell-indexes of 0, 1, 2 and 3.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; In the GPIO case of patch 3/3, these directly correspond the t=
he state of the two GPIO pins controlling the multiplexer. =A0The driver th=
en uses the cell-index property to determine the state of the GPIO to conne=
ct any given child.<br>

&gt;&gt;&gt;<br>
&gt;&gt;&gt; It is possible that the documentation part of the patch could =
be made more clear about this.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +Example :<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt; [...]<br>
&gt;&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; +int mdio_mux_probe(struct platform_device *pdev,<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int (*switch_fn)(=
int cur, int desired, void *data),<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *data)<br>
&gt;&gt;&gt;&gt;&gt; +{<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 struct device_node *parent_bus_node;<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 struct device_node *child_bus_node;<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 int r, n, ret_val;<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 struct mii_bus *parent_bus;<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 struct mdio_mux_parent_bus *pb;<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 struct mdio_mux_child_bus *cb;<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 if (!pdev-&gt;dev.of_node)<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 parent_bus_node =3D of_parse_phandle(pde=
v-&gt;dev.of_node, &quot;parent-bus&quot;, 0);<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 if (!parent_bus_node)<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;<br>
&gt;&gt;&gt;&gt;&gt; +<br>
&gt;&gt;&gt;&gt;&gt; + =A0 =A0 =A0 parent_bus =3D of_mdio_find_bus(parent_b=
us_node);<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; So what happens if the parent bus probe happens after the =
mux probe?<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; The whole house of cards collapses.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Grant Likely has a patch to deal with this by retrying the pro=
bing, =A0but as far as I know, it has not been merged yet.<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt; - k--<br>
&gt;&gt; To unsubscribe from this list: send the line &quot;unsubscribe net=
dev&quot; in<br>
&gt;&gt; the body of a message to <a href=3D"mailto:majordomo-u79uwXL29TbrhsbdSgBK9A@public.gmane.org=
rg">majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a><br>
&gt;&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majord=
omo-info.html">http://vger.kernel.org/majordomo-info.html</a><br>
&gt;&gt;<br>
&gt;<br>
</p>

--20cf307d0050b1886104acf022bc--

--===============7977552771947630206==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============7977552771947630206==--
