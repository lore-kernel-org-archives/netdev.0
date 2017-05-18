From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 15:21:39 -0700
Message-ID: <08a89dd5-b707-8b8f-b8e1-e20b9ed630b7@gmail.com>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
 <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com>
 <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
 <20170518193453.GB13759@lunn.ch>
 <CAMuHMdV+jfh=EGt3SvjtrtVfWQ6P8ofp_JxeQZjRrSEfDWs5hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdV+jfh=EGt3SvjtrtVfWQ6P8ofp_JxeQZjRrSEfDWs5hA@mail.gmail.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2017 01:36 PM, Geert Uytterhoeven wrote:
> Hi Andrew,
> 
> On Thu, May 18, 2017 at 9:34 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>>> This most certainly works fine in the simple case where you have one PHY
>>>> hanging off the MDIO bus, now what happens if you have several?
>>>>
>>>> Presumably, the first PHY that returns EPROBE_DEFER will make the entire
>>>> bus registration return EPROB_DEFER as well, and so on, and so forth,
>>>> but I am not sure if we will be properly unwinding the successful
>>>> registration of PHYs that either don't have an interrupt, or did not
>>>> return EPROBE_DEFER.
>>>>
>>>> It should be possible to mimic this behavior by using the fixed PHY, and
>>>> possibly the dsa_loop.c driver which would create 4 ports, expecting 4
>>>> fixed PHYs to be present.
>>>
>>> mdiobus_unregister(), called from of_mdiobus_register() on failure,
>>> should do the unwinding, right?
>>>
>>> And when the driver is reprobed, all PHYs are reprobed, until they all
>>> succeed.
>>
>> That is the theory. I looked at that while reviewing the patch. But
>> this has probably not been tested in anger. It would be good to test
>> this properly, with not just the first PHY returning -EPROBE_DEFER, to
>> really test the unwind.
> 
> Unfortunately I don't have a board with multiple PHYs, so I cannot test
> that case.
> 
> Does unbinding/rebinding a network driver with multiple PHYs currently
> work? Or module unload/reload?

Usually there is a strict 1:1 mapping between a network device (not
driver) and a PHY device, switch drivers however, would have multiple
PHYs (one per port, aka net_deice).

NB: binding and unbinding of PHYs is pretty broken at the moment though,
because there is a complete disconnect between what the Ethernet MAC
expects, and the state in which the PHY is. I had some patches to fix
that, but this turned out to be playing whack-a-mole which I typically
suck at.
-- 
Florian
