From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH] net: ftgmac100: Request clock and set speed
Date: Tue, 10 Oct 2017 14:38:09 +0930
Message-ID: <CACPK8XeEMJ_uWBNQihy_tZhqBhZWoOaS_6pkyiCO_RxBMaYimg@mail.gmail.com>
References: <20171010044925.21078-1-joel@jms.id.au> <0150f64f-6093-1cca-465b-8ec158abe7e6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andrew Jeffery <andrew@aj.id.au>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0150f64f-6093-1cca-465b-8ec158abe7e6@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 2:34 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
>
> On 10/09/2017 09:49 PM, Joel Stanley wrote:
>> According to the ASPEED datasheet, gigabit speeds require a clock of
>> 100MHz or higher. Other speeds require 25MHz or higher.
>>
>> Signed-off-by: Joel Stanley <joel@jms.id.au>
>> ---
>
>> @@ -161,6 +170,9 @@ static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
>>               break;
>>       }
>>
>> +     if (freq && priv->clk)
>> +             clk_set_rate(priv->clk, freq);
>
> Checking for priv->clk should not be necessary all public clk APIs can
> deal with a NULL clock pointer.

The intention was to set ->clk to NULL to indicate that there was no
clk, and therefore there is no reason to attempt to set the rate or
call prepare/unprepare.

If the we prefer to call the clk apis unconditionally I will send a v2
with the checks removed.

Thanks for the review.

Cheers,

Joel
