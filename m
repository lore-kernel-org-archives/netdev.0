From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: dsa: loop: Check for memory allocation failure
Date: Mon, 8 May 2017 12:05:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE715E@AcuExch.aculab.com>
References: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Christophe JAILLET' <christophe.jaillet@wanadoo.fr>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET
> Sent: 06 May 2017 06:30
> If 'devm_kzalloc' fails, a NULL pointer will be dereferenced.
> Return -ENOMEM instead, as done for some other memory allocation just a
> few lines above.
...
> --- a/drivers/net/dsa/dsa_loop.c
> +++ b/drivers/net/dsa/dsa_loop.c
> @@ -256,6 +256,9 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
>  		return -ENOMEM;
> 
>  	ps = devm_kzalloc(&mdiodev->dev, sizeof(*ps), GFP_KERNEL);
> +	if (!ps)
> +		return -ENOMEM;
> +
>  	ps->netdev = dev_get_by_name(&init_net, pdata->netdev);
>  	if (!ps->netdev)
>  		return -EPROBE_DEFER;

On the face if it this code leaks like a sieve.

	David
