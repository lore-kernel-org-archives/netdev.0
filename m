From: U Bhaskar-B22300 <B22300@freescale.com>
Subject: RE: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Tue, 9 Aug 2011 09:34:59 +0000
Message-ID: <9C64B7751C3BCA41B64A68E23005A7BE1BEFCE@039-SN1MPN1-004.039d.mgd.msft.net>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
	<1312641270-6018-6-git-send-email-holt@sgi.com>
	<4E3FA066.3020301@grandegger.com>	<20110808113136.GS4926@sgi.com>
	<4E3FDFC9.7080508@grandegger.com>	<20110808135630.GU4926@sgi.com>
	<4E3FEFBB.9050103@grandegger.com>	<20110808142153.GW4926@sgi.com>
	<4E3FF4B8.2010603@grandegger.com>	<20110808144424.GY4926@sgi.com>
 <4E3FF9EA.6030601@grandegger.com> <4E3FFD5B.7080000@pengutronix.de>
 <4E4001E1.3030508@grandegger.com> <4E403097.4020306@pengutronix.de>
 <9C64B7751C3BCA41B64A68E23005A7BE1B9D6C@039-SN1MPN1-002.039d.mgd.msft.net>
 <4E40EC14.1010005@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:32316
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752448Ab1HIJfG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 05:35:06 -0400
In-Reply-To: <4E40EC14.1010005@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
> Sent: Tuesday, August 09, 2011 1:43 PM
> To: U Bhaskar-B22300
> Cc: Wolfgang Grandegger; socketcan-core@lists.berlios.de;
> netdev@vger.kernel.org
> Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
> 
> On 08/09/2011 09:57 AM, U Bhaskar-B22300 wrote:
> >> On 08/08/2011 05:33 PM, Wolfgang Grandegger wrote:
> >>>> ACK - The device tree bindings as in mainline's Documentation is a
> >> mess.
> >>>> If the powerpc guys are happy with a clock interfaces based
> >>>> approach somewhere in arch/ppc, I'm more than happy to remove:
> >>>> - fsl,flexcan-clock-source (not implemented, even in the fsl
> >>>> driver)
> 
> > [Bhaskar]I have pushed the FlexCAN series of patches, It contains the
> > usage of all the fields posted in the FlexCAN bindings at
> > http://git.kernel.org/?p=linux/kernel/git/stable/linux-3.0.y.git;a=blo
> > b;f=Documentation/devicetree/bindings/net/can/fsl-flexcan.txt;h=1a729f
> > 089866259ef82d0db5893ff7a8c54d5ccf;hb=94ed5b4788a7cdbe68bc7cb8516972cb
> > ebdc8274
> 
> I've commented the patches. They are in a very bad shape. Please test
> Robin's patches.
> 
> >>>>
> >>>> - fsl,flexcan-clock-divider \__ replace with code in arch/ppc, or
> >>>> - clock-frequency           /   a single clock-frequency attribute
> >>>
> >>> In the "net-next-2.6" tree there is also:
> >>>
> >>>  $ grep flexcan arch/powerpc/boots/dts/*.dts
> >>>   p1010rdb.dts:			fsl,flexcan-clock-source =
> "platform";
> >>>   p1010rdb.dts:			fsl,flexcan-clock-source =
> "platform";
> >>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
> >>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
> >>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
> >>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
> >>>
> >>> Especially the fsl,flexcan-clock-divider = <2>; might make people
> >>> think, that they could set something else.
> >>
> > [Bhaskar] As it is mentioned in the Flexcan bindings, the need of
> > fsl,flexcan-clock-divider = <2>; But I kept it as "2" because FlexCan
> > clock source is the platform clock and it is CCB/2 If the "2" is
> > misleading, the bindings can be changed or some text can be written to
> > make the meaning of "2" Understandable , Please suggest ..
> 
> The clock devider is crap. Why not specify the clockrate that goes into
> the flexcan core?
[Bhaskar] The reason why I placed the "fsl,flexcan-clock-divider" property is just because the earlier implementations
		 Of CAN also follows the same approach. Please see below the approach of mscan.
                compatible = "fsl,mpc5121-mscan";
                interrupts = <13 0x8>;
                interrupt-parent = <&ipic>;
                reg = <0x1380 0x80>;
                fsl,mscan-clock-source = "ref";
                fsl,mscan-clock-divider = <3>;
        };
	If you want we can remove the fsl,flexcan-clock-divider property. Please comment ..
	
> 
> cheers, Marc
> 
> --
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


