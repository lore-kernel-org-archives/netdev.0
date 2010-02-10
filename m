From: "M. Warner Losh" <imp-uzTCJ5RojNnQT0dZR+AlfA@public.gmane.org>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 11:37:20 -0700 (MST)
Message-ID: <20100210.113720.1026572228166328165.imp@bsdimp.com>
References: <7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
	<fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
	<4B72FAB2.5000804@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	afleming-KZfg59tc24xl57MIdRCFDg@public.gmane.org
To: scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4B72FAB2.5000804-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In message: <4B72FAB2.5000804-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
            Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org> writes:
: Grant Likely wrote:
: >> 1. What if we just don't specific a phy address with a reg property
: >> which would specify to auto probe it and find the phy as illustrated
: >> below?
: >>
: >>
: >>                Ethernet_MAC: ethernet@81000000 {
: >>                        #address-cells = <1>;
: >>                        #size-cells = <1>;
: >>                        phy-handle = <&phy0>;
: >>                        mdio {
: >>                                #address-cells = <1>;
: >>                                #size-cells = <0>;
: >>                                phy0: phy@7 {
: >>                                } ;
: >>                        } ;
: >>
: >> 2. Or a special value (-1 or something not 0 - 31) in the phy address
: >> that specifies to auto probe as illustrated below.
: >>                                phy0: phy@7 {
: >>                                        reg = <-1>;
: >>                                } ;
: > I don't like abusing the reg property in this way.  I wonder if a new
: > empty property would be a better way to indicate this.  Maybe
: > "phy-probe-address;"?  It would also be important to specify in the
: > binding that only one phy node is allowed when phy-probe-address is
: > used.
: > Also, without a known reg the 'phy@7' name is inaccurate.  Drop the
: > @7.
: > Scott, Andy: any thoughts?
: 
: I'm not fond of the -1.  I'd prefer the explicit phy-probe-address
: property, though I don't mind too much using the absence of reg.

There are times that you'd want a list of PHY addresses to use.  This
suggests a bitmask, but I don't know if they are common enough to
warrant the extra burden on the usual case...

Warner
