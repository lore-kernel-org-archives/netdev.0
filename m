From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: unconditionally set ATU
 trunk
Date: Tue, 28 Mar 2017 12:29:19 -0700
Message-ID: <29073565-c03a-f684-6b49-b5226cbdd61b@gmail.com>
References: <20170328190943.18320-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328190943.18320-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/28/2017 12:09 PM, Vivien Didelot wrote:
> Set the trunk member of the mv88e6xxx_atu_entry structure regardless its
> value, so that uninitialized structures gets the correct boolean value.

Ouch, yes indeed!

> 
> Note that no mainline code is affected by the current behavior.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/dsa/mv88e6xxx/global1_atu.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
> index 831434bc5c13..fa7e7db5171b 100644
> --- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
> +++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
> @@ -128,9 +128,7 @@ static int mv88e6xxx_g1_atu_data_read(struct mv88e6xxx_chip *chip,
>  
>  	entry->state = val & 0xf;
>  	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
> -		if (val & GLOBAL_ATU_DATA_TRUNK)
> -			entry->trunk = true;
> -
> +		entry->trunk = !!(val & GLOBAL_ATU_DATA_TRUNK);
>  		entry->portvec = (val >> 4) & mv88e6xxx_port_mask(chip);
>  	}
>  
> 


-- 
Florian
