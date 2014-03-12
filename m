From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2a RESEND 2/2] of_mdio: Allow the DT to specify the phy
 ID and avoid autoprobing
Date: Thu, 13 Mar 2014 01:46:18 +0300
Message-ID: <5320E3BA.5070309@cogentembedded.com>
References: <1394658311-17769-1-git-send-email-jgunthorpe@obsidianresearch.com> <1394658311-17769-2-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394658311-17769-2-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/13/2014 12:05 AM, Jason Gunthorpe wrote:

> This makes the generic of_mdiobus_register parse the DT compatible string for
> the pattern ethernet-phy-idAAAA.BBBB. If present it should be a value that
> matches the phy-id register normally readable through MDIO.

> When the ID is given the phy autoprobing is defeated and the phy is
> created directly.

> This is necessary to support phy's that cannot be autoprobed when
> of_mdiobus_register is called. Specifically, my case has the phy in reset at
> of_mdiobus_register, the reset is only released once the ethernet driver
> starts, before it attaches to the phy.

> Tested on ARM Kirkwood with phy id 0x01410e90 (Marvell 88E1318)

> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/of/of_mdio.c | 30 +++++++++++++++++++++++++++++-
>   1 file changed, 29 insertions(+), 1 deletion(-)

> There was some reworking of the original code in v3.14-rc6, this resolves the
> merge conflicts and I retested the resolved patch on Kirkwood.

> Florian, do you know what path to mainline a this patch should take?

> Thanks,
> Jason

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 5b3c24f..6cdcbda 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -43,6 +43,30 @@ static void of_set_phy_supported(struct phy_device *phydev, u32 max_speed)
>   	}
>   }
>
> +/* Extract the clause 22 phy ID from the compatible string of the form
> + * ethernet-phy-idAAAA.BBBB */

    The preferred multi-line comment style is:

/*
  * bla
  * bla
  */

WBR, Sergei
