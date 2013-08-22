From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH] phylib: mdio: handle register/unregister/register sequence
Date: Thu, 22 Aug 2013 13:43:37 +0100
Message-ID: <CAGVrzcaByva=8xiswcsW1B8G4dL=jY0RdaHKzNqaT_0Lrwbprg@mail.gmail.com>
References: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Nick Bowler <nbowler@elliptictech.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Boris BREZILLON <b.brezillon@overkiz.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Boris,

2013/8/22 Boris BREZILLON <b.brezillon@overkiz.com>:
> Hello,
>
> This patch is a proposal to support the register/unregister/register
> sequence on a given mdio bus.
>
> I use the register/unregister/register sequence to add a fallback when the
> of_mdiobus_register (this function calls mdiobus_register with phy_mask
> set to ~0) does not register any phy device (because the device tree does
> not define any phy).
> In this case I call mdiobus_unregister and then call mdiobus_register with
> a phy_mask set to 0 to trigger a full mdio bus scan.
>
> I'm not sure this is the right way to do it (this is why I added RFC in the
> subject).
>
> Could someone help me figuring out what I should use to implement my fallback ?
>
> 1) use the register/unregister/register sequence
> 2) reimplement the "for (i = 0; i < PHY_MAX_ADDR; i++)" mdiobus_scan loop

I think solution 2 is nicer, in that case, would it be enough in your
case to export a function called mdiobus_scan()? You could call at a
time you know PHY devices have a chance of having been probed?
-- 
Florian
