From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5 SoCs
Date: Wed, 21 Sep 2016 11:32:18 +0930
Message-ID: <CACPK8Xde3COqQ8euhj3Ww5pPiAn4iXvMqJVpjKu3eGa1Pm=1GA@mail.gmail.com>
References: <20160920063007.24291-1-joel@jms.id.au> <20160920063007.24291-7-joel@jms.id.au>
 <1474373594.2857.62.camel@kernel.crashing.org> <20160920152940.GI22292@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Andrew Jeffery <andrew@aj.id.au>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920152940.GI22292@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2016 at 12:59 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Sep 20, 2016 at 10:13:14PM +1000, Benjamin Herrenschmidt wrote:
>> On Tue, 2016-09-20 at 16:00 +0930, Joel Stanley wrote:
>> > On Aspeed SoC with a direct PHY connection (non-NSCI), we receive
>> > continual PHYSTS interrupts:
>> >
>> >  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>> >  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>> >  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>> >  [   20.300000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>> >
>> > This is because the driver was enabling low-level sensitive interrupt
>> > generation where the systems are wired for high-level. All CPU cycles
>> > are spent servicing this interrupt.
>>
>> If this is a system wiring issue, should it be represented by a DT
>> property ?
>
> Is there a device tree binding document somewhere?
>
> Is it possible just to put ACTIVE_HIGH in the right place in the
> binding?

I wrote "wired for high level" wrt the SoC internals. To be honest I
wondered the same thing but it's hard with only one (non-NSCI) system
to test on.

I had a look at the eval board schematic and it appears that the line
has pull down resistors on it, explaining why the IRQ fires when it's
configured to active low. Other machines re-use the pin pin as a GPIO.
So yes, I will change this to a dt property in v2. That will mean
dropping 4/7 "net/faraday: Avoid PHYSTS_CHG interrupt" as well.

Cheers,

Joel
