From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Thu, 23 Aug 2012 20:46:30 -0600
Message-ID: <5036EB06.7060807@wwwdotorg.org>
References: <1345751071-23128-1-git-send-email-timur@freescale.com>
 <5036B4BD.70208@wwwdotorg.org>
 <6AE080B68D46FC4BA2D2769E68D765B7059D1DC7@039-SN2MPN1-022.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 Fleming Andy-AFLEMING <afleming-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Tabi Timur-B04825 <B04825-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <6AE080B68D46FC4BA2D2769E68D765B7059D1DC7-RL0Hj/+nBVC81RJBUSuqCa4g8xLGJsHaLnY5E4hWTkheoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/23/2012 06:28 PM, Tabi Timur-B04825 wrote:
> Stephen Warren wrote:
>> On 08/23/2012 01:44 PM, Timur Tabi wrote:
>>> Add support for an MDIO bus multiplexer controlled by a simple memory-mapped
>>> device, like an FPGA.  The device must be memory-mapped and contain only
>>> 8-bit registers (which keeps things simple).
>>
>>> +++ b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
>>
>>> +	/* The FPGA node */
>>> +	fpga: board-control@3,0 {
>>> +		compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
>>> +		reg = <3 0 0x30>;
>>
>> Why not add the following here:
>>
>> 	#address-cells = <1>:
>> 	#size-cells = <1>;
>> 	ranges = <...>;
> 
> I forgot to add them in the txt file.  They are in the real device tree.
> 
>>
>>> +
>>> +		mdio-mux-emi2 {
>>> +			compatible = "mdio-mux-mmioreg", "mdio-mux";
>>> +			mdio-parent-bus = <&xmdio0>;
>>> +			#address-cells = <1>;
>>> +			#size-cells = <0>;
>>> +			reg = <9>; // BRDCFG1
>>
>> Then, that'd have to be <9 1>;
> 
> Actually, I had #size-cells = <0>.

I think that if you have #size-cells=<0>, then you'll see the following
error message when attempting to translate the address into the parent's
address space:

prom_parse: Bad cell count for /board-control@3,0/mdio-mux-emi2

I fixed that error for cases where actual address translation isn't
required (i.e. coming up with the platform device name), but IIRC it'll
still trigger if you actually want to translate the address.
