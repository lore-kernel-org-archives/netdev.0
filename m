From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v2a 1/2] dt: Document a compatible entry for MDIO ethernet
 Phys
Date: Thu, 20 Mar 2014 09:26:28 +0100
Message-ID: <532AA634.5090707@codethink.co.uk>
References: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/03/14 23:15, Jason Gunthorpe wrote:
> This describes a compatible entry of the form:
>    ethernet-phy-idAAAA,BBBB
> Which is modelled after the PCI structured compatible entry
> (pciVVVV,DDDD.SSSS.ssss.RR)
>
> If present the OF core will be able to use this information to
> directly create the correct phy without auto probing the bus.
>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Acked-by: Rob Herring <robh@kernel.org>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   Documentation/devicetree/bindings/net/phy.txt | 10 +++++++++-
>   1 file changed, 9 insertions(+), 1 deletion(-)
>
> - Resend for net-next
>
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index 58307d0..5b8c589 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -21,10 +21,18 @@ Optional Properties:
>     elements.
>   - max-speed: Maximum PHY supported speed (10, 100, 1000...)
>
> +  If the phy's identifier is known then the list may contain an entry
> +  of the form: "ethernet-phy-idAAAA.BBBB" where
> +     AAAA - The value of the 16 bit Phy Identifier 1 register as
> +            4 hex digits. This is the chip vendor OUI bits 3:18
> +     BBBB - The value of the 16 bit Phy Identifier 2 register as
> +            4 hex digits. This is the chip vendor OUI bits 19:24,
> +            followed by 10 bits of a vendor specific ID.
> +

How about having "ethernet-phy" and adding a single property in the
PHY node saying phy-id = <AAAABBBB>, which would be much easier to
parse.

>   Example:
>
>   ethernet-phy@0 {
> -	compatible = "ethernet-phy-ieee802.3-c22";
> +	compatible = "ethernet-phy-id0141.0e90", "ethernet-phy-ieee802.3-c22";
>   	interrupt-parent = <40000>;
>   	interrupts = <35 1>;
>   	reg = <0>;
>


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
