From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 17/18] net: dsa: mv88e6xxx: support the VTU Page
 bit
Date: Fri, 28 Apr 2017 14:53:53 +0200
Message-ID: <20170428125353.GK13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-18-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44414 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2993681AbdD1Mx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 08:53:57 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-18-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:35AM -0400, Vivien Didelot wrote:
> Newer chips such as the 88E6390 have a VTU Page bit in the VTU VID
> register to specify a 13th bit for the VID. This can be used to support
> 8K VLANs.

Hi Vivien

At the moment, this code appears to be generic to all chips. Do we
need checks to ensure we don't look at this bit on older devices where
it is not valid? Particularly on read. On write, we already verify the
vid is less than info->max_vids, so i don't think that is a problem.

> When dumping the whole VTU, all VID bits must be set to one, including
> this VTU Page bit. Add support for VID greater than 4095.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/global1_vtu.c | 7 +++++++
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   | 1 +
>  2 files changed, 8 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
> index cb0f3359d60b..2ad080291208 100644
> --- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
> +++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
> @@ -95,6 +95,10 @@ static int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
>  		return err;
>  
>  	entry->vid = val & 0xfff;
> +
> +	if (val & GLOBAL_VTU_VID_PAGE)
> +		entry->vid |= 0x1000;
> +

I'm undecided myself, so i will just bring it up for discussion.

Maybe it would be more readable to say:

		entry->vid += 4096;

???

	Andrew
