From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH net] mdio: mux: fix parsing mux registers outside of the
 PHY address range
Date: Mon, 10 Jul 2017 10:28:39 -0400
Message-ID: <CAC3K-4p0gidfh1U+_o3i7bwCgQo1QtNb7D+MXwYa+X_-9sFhrw@mail.gmail.com>
References: <20170710123523.6625-1-martin.blumenstingl@googlemail.com> <20170710125652.GG1616@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-amlogic@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35808 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932304AbdGJO2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 10:28:40 -0400
Received: by mail-it0-f47.google.com with SMTP id v202so34751942itb.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 07:28:40 -0700 (PDT)
In-Reply-To: <20170710125652.GG1616@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 8:56 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, Jul 10, 2017 at 02:35:23PM +0200, Martin Blumenstingl wrote:
>> mdio_mux_init parses the child nodes of the MDIO mux. When using
>> "mdio-mux-mmioreg" the child nodes are describing the register value
>> that is written to switch between the MDIO busses.
>>
>> The change which makes the error messages more verbose changed the
>> parsing of the "reg" property from a simple of_property_read_u32 call
>> to of_mdio_parse_addr. On a Khadas VIM (based on the Meson GXL SoC,
>> which uses mdio-mux-mmioreg) this prevents registering the MDIO mux
>> (because the "reg" values on the MDIO mux child nodes are 0x2009087f
>> and 0xe40908ff) and leads to the following errors:
>>   mdio-mux-mmioreg c883455c.eth-phy-mux: /soc/periphs@c8834000/eth-phy-mux/mdio@e40908ff PHY address -469169921 is too large
>>   mdio-mux-mmioreg c883455c.eth-phy-mux: Error: Failed to find reg for child /soc/periphs@c8834000/eth-phy-mux/mdio@e40908ff
>>   mdio-mux-mmioreg c883455c.eth-phy-mux: /soc/periphs@c8834000/eth-phy-mux/mdio@2009087f PHY address 537462911 is too large
>>   mdio-mux-mmioreg c883455c.eth-phy-mux: Error: Failed to find reg for child /soc/periphs@c8834000/eth-phy-mux/mdio@2009087f
>>   mdio-mux-mmioreg c883455c.eth-phy-mux: Error: No acceptable child buses found
>>   mdio-mux-mmioreg c883455c.eth-phy-mux: failed to register mdio-mux bus /soc/periphs@c8834000/eth-phy-mux
>> (as a result of that ethernet is not working, because the PHY which is
>> connected through the mux' child MDIO bus, which is not being
>> registered).
>>
>> Fix this by reverting the change from of_mdio_parse_addr to
>> of_mdio_parse_addr.
>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>
> Yes, validating the reg property needs to be done separately in each
> user of the generic mdio-mix code. The reg for the gpio mux must be <=
> number of gpios, mmioreg must be somewhere within the address space,
> bcm-iproc < 1024?
>
> Jon, please feel free to add such code.

To be clear, are you suggesting that we add an additional property to
of_mdio_parse_addr() that specifies the limit to check against, or
remove the check and add it to each additional caller?

Thanks,
Jon

>
>     Andrew
