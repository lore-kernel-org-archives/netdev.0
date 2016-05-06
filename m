From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 14/20] net: dsa: mv88e6xxx: factorize VLAN
 Ethertype
Date: Fri, 6 May 2016 02:57:59 +0200
Message-ID: <20160506005759.GL7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-15-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58027 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211AbcEFA6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 20:58:01 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-15-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 06:40:58PM -0400, Vivien Didelot wrote:
> Only the 6131 driver was setting the VLAN Ethertype to 0x8100. Set it to
> all models.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6131.c | 9 ++++-----
>  drivers/net/dsa/mv88e6xxx.c | 8 ++++++++
>  drivers/net/dsa/mv88e6xxx.h | 7 +++++++
>  3 files changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
> index 013668c..4c0b1e9 100644
> --- a/drivers/net/dsa/mv88e6131.c
> +++ b/drivers/net/dsa/mv88e6131.c
> @@ -25,6 +25,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
>  		.num_databases = 256,
>  		.num_ports = 11,
>  		.flags = MV88E6XXX_FLAG_ATU |
> +			MV88E6XXX_FLAG_CORE_TAG_TYPE |
>  			MV88E6XXX_FLAG_PPU |
>  			MV88E6XXX_FLAG_VLANTABLE |
>  			MV88E6XXX_FLAG_VTU,
> @@ -35,6 +36,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
>  		.num_databases = 4096,
>  		.num_ports = 10,
>  		.flags = MV88E6XXX_FLAG_ATU |
> +			MV88E6XXX_FLAG_CORE_TAG_TYPE |
>  			MV88E6XXX_FLAG_PPU |
>  			MV88E6XXX_FLAG_VLANTABLE |
>  			MV88E6XXX_FLAG_VTU,
> @@ -45,6 +47,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
>  		.num_databases = 256,
>  		.num_ports = 8,
>  		.flags = MV88E6XXX_FLAG_ATU |
> +			MV88E6XXX_FLAG_CORE_TAG_TYPE |
>  			MV88E6XXX_FLAG_PPU |
>  			MV88E6XXX_FLAG_VLANTABLE |
>  			MV88E6XXX_FLAG_VTU,
> @@ -55,6 +58,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
>  		.num_databases = 256,
>  		.num_ports = 10,
>  		.flags = MV88E6XXX_FLAG_ATU |
> +			MV88E6XXX_FLAG_CORE_TAG_TYPE |
>  			MV88E6XXX_FLAG_PPU |
>  			MV88E6XXX_FLAG_VLANTABLE |
>  			MV88E6XXX_FLAG_VTU,

Hi Vivien

Rather than repeating these flags again and again, could you add one
#define containing the flags, and then use that to initialise .flags.

	Andrew
