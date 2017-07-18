From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 16:02:39 +0300
Message-ID: <8f6ca18a-b95c-458d-c19b-bf0186ff96e7@cogentembedded.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36831 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdGRNCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 09:02:42 -0400
Received: by mail-lf0-f49.google.com with SMTP id d78so8759371lfg.3
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 06:02:41 -0700 (PDT)
In-Reply-To: <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2017 03:52 PM, Fabio Estevam wrote:

>>>>    Won't this result in kernel WARNING when GPIO is disabled?
>>
>>
>>    GPIO support, I was going to type...
>>
>>> Not sure if I understood your point, but gpiod_set_value_cansleep() is
>>> a no-op when the gpiod is NULL.
>>
>>
>>    Look at the stub in <linux/gpio/consumer.h>, it has WARN_ON(1).
>
> This patch does not alter the behavior of the driver with respect to
> GPIO being disabled,

    No, it does -- devm_gpiod_get_optinal() will return NULL in that case, 
bus->reset_gpio will remanin NULL, and you're removing the NULL checks around 
the gpiod_set_value_cansleep() calls. Perhaps it's the problem in the GPIO 
support though...

> so I still do not understand your concern.

    And now?

MBR, Sergei
