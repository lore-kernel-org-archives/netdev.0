From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: Fix fallout from tg3_readphy() value is zero on error
Date: Tue, 15 Feb 2005 10:18:14 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3DA3@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> @@ -793,9 +799,11 @@
>  
>  	tg3_writephy(tp, MII_TG3_CTRL, phy9_orig);
>  
> -	tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32);
> -	reg32 &= ~0x3000;
> -	tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
> +	if (tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32)) {
> +		reg32 &= ~0x3000;
> +		tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
> +	} else if (!err)
> +		err = -EBUSY;
>  
>  	return err;
>  }

Shouldn't this be:

> +	if (!tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32)) {
