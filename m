From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 5/6] net: dsa: mv88e6xxx: add VTU ops
Date: Fri, 17 Feb 2017 22:49:09 +0100
Message-ID: <20170217214909.GK6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170217150531.2181-6-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 17, 2017 at 10:05:30AM -0500, Vivien Didelot wrote:
> Because there are several variant of the VTU operations and because
> checking for the presence of an STU is not enough, add new ops to the
> info structure to describe the VTU operations that a chip supports.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c      | 58 +++++++++++++++++++++++++----------
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  8 ++++-
>  2 files changed, 49 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 7010c3313e35..256a209eef9b 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -1220,33 +1220,19 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
>  static int mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
>  				 struct mv88e6xxx_vtu_entry *entry)
>  {
> -	int err;
> -
>  	if (!mv88e6xxx_has_vtu(chip))
>  		return -EOPNOTSUPP;
>  
> -	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU))
> -		err = mv88e6352_g1_vtu_getnext(chip, entry);
> -	else
> -		err = mv88e6185_g1_vtu_getnext(chip, entry);
> -
> -	return err;
> +	return chip->info->ops->vtu_getnext(chip, entry);
>  }

You appear to be taking out code you just added in the previous patch.

Please think about structuring these patches different. We want these
ops, but i don't think you have the best way of getting there.

     Andrew
