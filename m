From: Gerhard Sittig <gsi@denx.de>
Subject: Re: [PATCH] net/dt: Add support for overriding phy configuration
 from device tree
Date: Thu, 16 Jan 2014 14:59:05 +0100
Message-ID: <20140116135905.GV20094@book.gsilab.sittig.org>
References: <1389821938-3126-1-git-send-email-matthew.garrett@nebula.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, kishon@ti.com
To: Matthew Garrett <matthew.garrett@nebula.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389821938-3126-1-git-send-email-matthew.garrett@nebula.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 15, 2014 at 16:38 -0500, Matthew Garrett wrote:
> 
> Some hardware may be broken in interesting and board-specific ways, such
> that various bits of functionality don't work. This patch provides a
> mechanism for overriding mii registers during init based on the contents of
> the device tree data, allowing board-specific fixups without having to
> pollute generic code.
> 
> Signed-off-by: Matthew Garrett <matthew.garrett@nebula.com>
> ---
>  Documentation/devicetree/bindings/net/phy.txt |  13 +++
>  drivers/net/phy/phy_device.c                  |  29 +++++-
>  drivers/of/of_net.c                           | 124 ++++++++++++++++++++++++++
>  include/linux/of_net.h                        |  12 +++
>  4 files changed, 177 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index 7cd18fb..552a5e0 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -23,6 +23,19 @@ Optional Properties:
>    assume clause 22. The compatible list may also contain other
>    elements.
>  
> +The following properties may be added to either the phy node or the parent
> +ethernet device:
> +
> +- phy-mii-advertise-10half: Whether to advertise half-duplex 10MBit
> +- phy-mii-advertise-10full: Whether to advertise full-duplex 10MBit
> +- phy-mii-advertise-100half: Whether to advertise half-duplex 100MBit
> +- phy-mii-advertise-100full: Whether to advertise full-duplex 100MBit
> +- phy-mii-advertise-100base4: Whether to advertise 100base4
> +- phy-mii-advertise-1000half: Whether to advertise half-duplex 1000MBit
> +- phy-mii-advertise-1000full: Whether to advertise full-duplex 1000MBit
> +- phy-mii-as-master: Configure phy to act as master/slave
> +- phy-mii-manual-master: Enable/disable manual master/slave configuration
> +
>  Example:
>  
>  ethernet-phy@0 {

These properties are booleans, and optional?  Does it mean that
you cannot _disable_ broken features?  Or does it mean that you
_must_ specify the non-broken features and thus break backwards
compatibility?  Or are these properties not boolean (they are not
used in the example either, unfortunately), and the binding text
would need an update for clarity?  What am I missing?


virtually yours
Gerhard Sittig
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr. 5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
