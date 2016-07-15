From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/3] net: smsc911x: augment device tree bindings
Date: Fri, 15 Jul 2016 14:03:41 -0500
Message-ID: <20160715190341.GA12624@rob-hp-laptop>
References: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>, devicetree@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35899 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbcGOTDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 15:03:44 -0400
Content-Disposition: inline
In-Reply-To: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 08, 2016 at 11:07:30AM +0200, Linus Walleij wrote:
> This adds device tree bindings for:
> 
> - An optional GPIO line for releasing the RESET signal to the
>   SMSC911x devices
> 
> - An optional PME (power management event) interrupt line that
>   can be utilized to wake up the system on network activity.
>   This signal exist on all the SMSC911x devices, it is just not
>   very often routed.
> 
> Both these lines are routed to the SoC on the Qualcomm APQ8060
> Dragonboard and thus needs to be bound in the device tree.
> 
> Cc: devicetree@vger.kernel.org
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
>  Documentation/devicetree/bindings/net/smsc911x.txt | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
> index 3fed3c124411..7b01c37272c1 100644
> --- a/Documentation/devicetree/bindings/net/smsc911x.txt
> +++ b/Documentation/devicetree/bindings/net/smsc911x.txt
> @@ -3,9 +3,12 @@
>  Required properties:
>  - compatible : Should be "smsc,lan<model>", "smsc,lan9115"
>  - reg : Address and length of the io space for SMSC LAN
> -- interrupts : Should contain SMSC LAN interrupt line
> -- interrupt-parent : Should be the phandle for the interrupt controller
> -  that services interrupts for this device
> +- interrupts/extended-interrupts : Should contain the SMSC LAN

It's interrupts-extended. Documentation-wise both are always supported, 
so we just document 'interrupts' unless interrupts-extended is only ever 
valid which would not be the case here.

> +  interrupt line as cell 0, cell 1 is an OPTIONAL PME (power
> +  management event) interrupt that is able to wake up the host
> +  system with a 50ms pulse on network activity
> +  For generic bindings for interrupt controller parents, refer to
> +  interrupt-controller/interrupts.txt
>  - phy-mode : See ethernet.txt file in the same directory
