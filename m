From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell
 PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 18:40:46 +0200
Message-ID: <5421A28E.7060600@gmail.com>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <4014272.rJbSfrLcuB@wuerfel> <542195B0.6080706@gmail.com> <9401592.hUYDkriFVO@wuerfel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9401592.hUYDkriFVO@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/23/2014 06:29 PM, Arnd Bergmann wrote:
> On Tuesday 23 September 2014 17:45:52 Sebastian Hesselbarth wrote:
>> For reference, this is what we have for MVEBU SoCs with multiple ports
>> per controller:
>>
>> eth: ethernet-ctrl@72000 {
>>          compatible = "marvell,orion-eth";
...
>>          reg = <0x72000 0x4000>;
...
>>
>>          ethernet-port@0 {
>>                  compatible = "marvell,orion-eth-port";
...
>>                  phy-handle = <&ethphy>;
>>          };
>> };
>>
>> mdio: mdio-bus@72004 {
>>          compatible = "marvell,orion-mdio";
...
>>          reg = <0x72004 0x84>;
..
>>          ethphy: ethernet-phy {
>>                  /* set phy address in board file */
>>          };
>> };

> But in this example, you have the same registers and the same
> clocks in two nodes, which are even used by the same device driver
> at the moment. It's not a big issue, but my feeling is that Antoine's
> approach was actually better because it more closely reflects
> the way that the hardware is built.

I was not referring to the separate mdio bus node, but putting the
ethernet-phy node as a child of ethernet-ctrl.

Anyway, I can live with the ethernet-phy being a child of the controller
node until we discover where it is hooked up.

For the internal MII PHY the controller node maybe is the only sane
place to put it in. The HEC PHY will reside within the CEC IP node but
that is compatible with Antoine's proposal.

Sebastian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
