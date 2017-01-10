From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net v2 5/5] net: qcom/emac: fix of_node and phydev leaks
Date: Tue, 10 Jan 2017 09:43:27 +0100
Message-ID: <20170110084327.GA3501@localhost>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
 <1480011691-13278-6-git-send-email-johan@kernel.org>
 <650c00e9-cf02-1764-5065-86f6c06817f3@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <650c00e9-cf02-1764-5065-86f6c06817f3@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 09, 2017 at 01:49:53PM -0600, Timur Tabi wrote:
> On 11/24/2016 12:21 PM, Johan Hovold wrote:
> > +	if (!has_acpi_companion(&pdev->dev))
> > +		put_device(&adpt->phydev->mdio.dev);
> 
> I was wondering if, instead of calling put_device() only on non-ACPI systems, 
> would it be better if on an ACPI system I called get_device() manually?  That 
> is, some thing like this:
> 
> int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
> {
> ...
> 	if (has_acpi_companion(&pdev->dev)) {
> ...
> 		get_device(&mii_bus->dev);
> 	} else {
> ...

Yeah, that's better.

Thanks,
Johan
