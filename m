From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/4] dsa: mv88e6xxx: Delete ppu timer when removing module
Date: Tue, 23 Aug 2016 16:37:34 +0300
Message-ID: <d20478f0-c11a-dfb2-26d0-a65db4119124@cogentembedded.com>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
 <1471874464-16142-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35442 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757203AbcHWNh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 09:37:58 -0400
Received: by mail-lf0-f45.google.com with SMTP id f93so101039093lfi.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 06:37:36 -0700 (PDT)
In-Reply-To: <1471874464-16142-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/22/2016 5:01 PM, Andrew Lunn wrote:

> The PPU method of accessing PHYs makes use of a timer. Make sure this
> timer is deleted before unloading the driver.
>
> Reported-by: Jamie Lentin <jm@lentin.co.uk>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index b315769aa5be..1d5f9576e62a 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
[...]
> @@ -3892,6 +3897,13 @@ static void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
>  	}
>  }
>
> +static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
> +{
> +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU)) {
> +		mv88e6xxx_ppu_state_destroy(chip);
> +	}

    {} not needed here. See Documentation/CodingStyle, chapter 3.

> +}
> +
>  static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
>  			      struct mii_bus *bus, int sw_addr)
>  {
[...]

MBR, Sergei
