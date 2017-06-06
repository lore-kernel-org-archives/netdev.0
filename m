From: Tony Lindgren <tony@atomide.com>
Subject: Re: phy: cpcap-usb: Add CPCAP PMIC USB support
Date: Tue, 6 Jun 2017 03:54:18 -0700
Message-ID: <20170606105418.GA3730@atomide.com>
References: <2ebfaf05-409b-f946-b2ad-f4e81c4439fa@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2ebfaf05-409b-f946-b2ad-f4e81c4439fa@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Colin Ian King <colin.king@canonical.com> [170605 10:58]:
> Hi Tony,
> 
> While running static analysis on linux-next, CoverityScan picked up a
> NULL pointer deference on ddata->pins when calling pinctrl_lookup_state:
> 
> 466        ddata->pins = devm_pinctrl_get(ddata->dev);
> 
>    1. Condition IS_ERR(ddata->pins), taking true branch.
> 
> 467        if (IS_ERR(ddata->pins)) {
> 468                dev_info(ddata->dev, "default pins not configured:
> %ld\n",
> 469                         PTR_ERR(ddata->pins));
> 
>    2. assign_zero: Assigning: ddata->pins = NULL.
> 
> 470                ddata->pins = NULL;
> 471        }
> 472
> 
>    CID 1440453 (#1 of 1): Explicit null dereferenced (FORWARD_NULL)3.
> var_deref_model: Passing null pointer ddata->pins to
> pinctrl_lookup_state, which dereferences it. [show details]
> 
> 473        ddata->pins_ulpi = pinctrl_lookup_state(ddata->pins, "ulpi");
> 
> 
> I suspect the IS_ERROR() check should return with some error return
> rather than continuing.

OK thanks for letting me know. I'll take a look and will
send a patch. The pinctrl_lookup_state() probably need to
happen only if ddata->pins as they are optional.

Regards,

Tony
