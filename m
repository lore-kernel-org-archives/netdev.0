From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 09/12] net: dsa: b53: Wire-up EEE
Date: Mon, 18 Sep 2017 18:29:22 -0400
Message-ID: <87mv5r1vzx.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-10-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36188 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdIRWcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:32:53 -0400
In-Reply-To: <20170918214128.27896-10-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> @@ -1000,6 +1005,9 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
>  			b53_write8(dev, B53_CTRL_PAGE, po_reg, gmii_po);
>  		}
>  	}
> +
> +	/* Re-negotiate EEE if it was enabled already */
> +	p->eee_enabled = b53_eee_init(ds, port, phydev);
>  }

Same here, I think we can move this up to DSA core, maybe with a
eee_enabled mask in dsa_switch or a bool in dsa_port.
