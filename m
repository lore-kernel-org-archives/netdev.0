From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC level
Date: Fri, 04 Nov 2016 16:49:39 +0000
Message-ID: <yw1x1syrjil8.fsf@unicorn.mansr.com>
References: <581CA300.1060609@laposte.net>
        <yw1xlgwzjmti.fsf@unicorn.mansr.com> <581CAB12.3030604@laposte.net>
        <b792b229-6126-c3a7-e071-bdd93fe51626@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Sebastian Frias <sf84@laposte.net>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b792b229-6126-c3a7-e071-bdd93fe51626@gmail.com> (Florian
        Fainelli's message of "Fri, 4 Nov 2016 09:28:52 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 11/04/2016 08:36 AM, Sebastian Frias wrote:
>> Hi Måns,
>> 
>> On 11/04/2016 04:18 PM, Måns Rullgård wrote:
>>> Sebastian Frias <sf84@laposte.net> writes:
>>>
>>>> The delay can be applied at PHY or MAC level, but since
>>>> PHY drivers will apply the delay at PHY level when using
>>>> one of the "internal delay" declinations of RGMII mode
>>>> (like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
>>>> at MAC level causes issues.
>>>
>>> The Broadcom GENET driver does the same thing.
>>>
>> 
>> Well, I don't know who uses that driver, or why they did it that way.
>
> I do use this driver and it works for me (tm), although I tested mostly
> with Broadcom PHYs and Ethernet switches, rarely with third party PHYs,
> but had that too, but all of that is in tree though,
> drivers/net/phy/broadcom.com, drivers/net/dsa/b53/ so feel free to
> "audit" that part of the code too.
>
> The configuration of the GENET port multiplexer requires us to specify
> how we want to align the clock and data, if we don't do that, and the
> PHY is also not agreeing with how its own delays should be configured,
> mayhem ensues, ranging from occasional transmit success, to high rates
> of CRC/FCS errors in best cases.
>
> I did verify that the settings were correct using a scope FWIW.
>
>> 
>> However, with the current code and DT bindings, if one requires
>> the delay, phy-connection-type="rgmii-txid" must be set.
>
> Yes, and we would set it correctly for our Broadcom reference boards
> using this driver.
>
>> 
>> But when doing so, both the Atheros 8035 and the Aurora NB8800 drivers
>> will apply the delay.
>> 
>> I think a better way of dealing with this is that both, PHY and MAC
>> drivers exchange information so that the delay is applied only once.
>
> Exchange what information? The PHY device interface (phydev->interface)
> conveys the needed information for both entities.

There doesn't seem to be any consensus among the drivers regarding where
the delay should be applied.  Since only a few drivers, MAC or PHY, act
on this property, most combinations still work by chance.  It is common
for boards to set the delay at the PHY using external config pins so no
software setup is required (although I have one Sigma based board that
gets this wrong).  I suspect if drivers/net/ethernet/broadcom/genet were
used with one of the four PHY drivers that also set the delay based on
this DT property, things would go wrong.

-- 
Måns Rullgård
