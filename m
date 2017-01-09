From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH net v2 5/5] net: qcom/emac: fix of_node and phydev leaks
Date: Mon, 9 Jan 2017 13:49:53 -0600
Message-ID: <650c00e9-cf02-1764-5065-86f6c06817f3@codeaurora.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
 <1480011691-13278-6-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-6-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/24/2016 12:21 PM, Johan Hovold wrote:
> +	if (!has_acpi_companion(&pdev->dev))
> +		put_device(&adpt->phydev->mdio.dev);

I was wondering if, instead of calling put_device() only on non-ACPI systems, 
would it be better if on an ACPI system I called get_device() manually?  That 
is, some thing like this:

int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
{
...
	if (has_acpi_companion(&pdev->dev)) {
...
		get_device(&mii_bus->dev);
	} else {
...

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
