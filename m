From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add addressing
 mode to info
Date: Wed, 15 Jun 2016 00:09:41 +0200
Message-ID: <20160614220941.GJ12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 02:31:53PM -0400, Vivien Didelot wrote:
> When the SMI address of the switch chip on the SMI master bus is not
> zero, some chips (e.g. 88E6352) use an indirect access through two SMI
> Command and Data registers, while others (e.g. 88E6060) still use a
> direct access.
> 
> Add a capability flag to describe chips supporting the Multi-chip
> Addressing Mode.
> 
> Use the SMI indirect access ops only for switches with this flag and
> change the direct SMI direct access ops to support non-zero chip
> address.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c |  6 +++---
>  drivers/net/dsa/mv88e6xxx.h | 16 +++++++++++++++-
>  2 files changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index fc28a6c..8e12246 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -52,7 +52,7 @@ static int mv88e6xxx_smi_direct_read(struct mii_bus *bus, int sw_addr,
>  {
>  	int ret;
>  
> -	ret = mdiobus_read_nested(bus, addr, reg);
> +	ret = mdiobus_read_nested(bus, sw_addr + addr, reg);
>  	if (ret < 0)
>  		return ret;

If we are doing direct access, doesn't it means sw_addr is 0?

So isn't this pointless?

   Andrew
