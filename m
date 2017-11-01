From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: Re: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Wed, 1 Nov 2017 13:43:03 +0100
Message-ID: <eeffcfd4-0d3c-79cb-7d26-ac84acaec1e8@maciej.szmigiero.name>
References: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
 <20171101121611.GD12680@lunn.ch>
 <b789b023-2e7b-1f5b-59a6-9676db74e850@maciej.szmigiero.name>
 <20171101123705.GG12680@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101123705.GG12680@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 01.11.2017 13:37, Andrew Lunn wrote:
> Hi Maciej
> 
> I don't particularly like the
> 
>        if (!phy->link)
>                 goto out_change_speed;
> 
> part of the existing code. Makes me thing of BASIC. goto is good for
> error handling, but this is not an error.
> 
> If you feel like it, maybe you can refactor this code? Add a function like:
> 
> phy_led_trigger_no_link(struct phy_device *phy)
> {
>         if (phy->last_triggered) {
>                 led_trigger_event(&phy->last_triggered->trigger,
>                                   LED_OFF);
>                 phy->last_triggered = NULL;
>         }
> }
> 
> and call it, rather than using goto? It then becomes a lot more
> obvious what your change is doing, turning the LED off when there is
> no link.

All right, will do this, too.

> Thanks
>    Andrew
> 

Maciej
