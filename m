From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next 1/4] dt-bindings: net: dsa: add Mediatek MT7530
 binding
Date: Tue, 14 Mar 2017 14:52:03 +0800
Message-ID: <1489474323.1870.47.camel@mtkswgap22>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
         <1489421488-300-2-git-send-email-sean.wang@mediatek.com>
         <928d1178-e04a-3e78-4a7a-36127321a949@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <vivien.didelot@savoirfairelinux.com>,
        <matthias.bgg@gmail.com>, <robh+dt@kernel.org>,
        <mark.rutland@arm.com>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <davem@davemloft.net>,
        <Landen.Chao@mediatek.com>, <keyhaede@gmail.com>,
        <objelf@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <928d1178-e04a-3e78-4a7a-36127321a949@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-13 at 09:47 -0700, Florian Fainelli wrote:
> On 03/13/2017 09:11 AM, sean.wang@mediatek.com wrote:
> > From: Sean Wang <sean.wang@mediatek.com>
> > 
> > Add device-tree binding for Mediatek MT7530 switch.
> > 
> > Cc: devicetree@vger.kernel.org
> > Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> > ---
> >  .../devicetree/bindings/net/dsa/mt7530.txt         | 94 ++++++++++++++++++++++
> >  1 file changed, 94 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/dsa/mt7530.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/dsa/mt7530.txt b/Documentation/devicetree/bindings/net/dsa/mt7530.txt
> > new file mode 100644
> > index 0000000..0e50dbf
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/dsa/mt7530.txt
> > @@ -0,0 +1,94 @@
> > +Mediatek MT7530 Ethernet switch
> > +================================
> > +
> > +Required properties:
> > +
> > +- compatible: Must be compatible = "mediatek,mt7530";
> > +- #address-cells: Must be 1
> > +- #size-cells: Must be 0
> > +- mediatek,ethsys: Phandle to the syscon node that handles the reset.
> > +- mediatek,ethernet: Phandle to the syscon node that Mediatek ethernet driver
> > +	provides that handles the TRGMII setup used by the switch.
> > +	See
> > +	Documentation/devicetree/bindings/net/mediatek-net.txt for the detailed
> > +	setup on mediatek ethernet.
> 
> This seems redundant with the CPU port's ethernet phandle here.


Okay, it is indeed better to reuse the phandle embedded in the cpu
ports. I will reuse this in the next one.

By the ways, I have a question which is could current DSA framework
allows managing the fabric designated from "multiple cpu ports" to "user
ports" in any combination in brctl and in other existing commands?

For example.

I assume that there are two cpu port called 5, and 6.and there are five
user ports called 0, 1, 2 and 3. and the default fabric on the switch is
mapping from { 5 } <-> { 0, 1, 2, 3 ,4 } where members in the braces I
assumes they also can communicate with each other.

Is it feasible for changing the fabric into other combinations in the
runtime such as 
{5} <-> {0, 1, 2, 3} and {6} <-> {4}
{5} <-> {0, 1, 2} and {6} <-> {3, 4} or 
{6} <-> {0, 1} and {6} <-> {2, 3, 4} or
....
{6} <-> {0, 1, 2, 3 ,4} ?

After some trace code, I found it seemed that only one cpu port could be
supported via one dsa registration. 

	Sean
