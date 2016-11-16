From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement disable
 options
Date: Wed, 16 Nov 2016 09:01:13 -0800
Message-ID: <d4e04f8a-77c5-f43e-5c24-d1238925543a@gmail.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
 <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
 <20161115163036.GB23231@lunn.ch>
 <476b72f3-5efe-3551-6c24-0e378d655a0f@gmail.com>
 <1479290189.17538.25.camel@baylibre.com> <20161116132337.GD19962@lunn.ch>
 <1479307890.17538.40.camel@baylibre.com> <20161116150628.GI23231@lunn.ch>
 <1479310731.17538.53.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479310731.17538.53.camel-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/16/2016 07:38 AM, Jerome Brunet wrote:
> On Wed, 2016-11-16 at 16:06 +0100, Andrew Lunn wrote:
>> On Wed, Nov 16, 2016 at 03:51:30PM +0100, Jerome Brunet wrote:
>>>
>>> On Wed, 2016-11-16 at 14:23 +0100, Andrew Lunn wrote:
>>>>
>>>>>
>>>>>
>>>>> There two kind of PHYs supporting eee, the one advertising eee
>>>>> by
>>>>> default (like realtek) and the one not advertising it (like
>>>>> micrel).
>>>
>>> This is just the default register value.
>>>
>>>>
>>>>
>>>> I don't know too much about EEE. So maybe a dumb question. Does
>>>> the
>>>> MAC need to be involved? Or is it just the PHY?
>>>>
>>>> If the MAC needs to be involved, the PHY should not be
>>>> advertising
>>>> EEE
>>>> unless the MAC asks for it by calling phy_init_eee(). If this is
>>>> true,
>>>> maybe we need to change the realtek driver, and others in that
>>>> class.
>>>
>>> As far I understand, the advertised capabilities are exchanged
>>> during
>>> the auto-negotiation.
>>>
>>> At this stage, if the advertisement is disabled (regarless of the
>>> actual support) on either side of the link, there will be no low
>>> power
>>> idle state on the Tx nor the Rx path.
>>>
>>> If the advertisement is enabled on both side but we don't call
>>> phy_init_eee, I suppose Tx won't enter LPI, but Rx could.
>>
>> What i was trying to find out is, if the MAC needs to support EEE as
>> well as the PHY, what happens when the MAC does not support EEE, but
>> the PHYs do negotiate EEE? Does it break?
> 
> Interesting question. In a regular case, I suppose it should be fine.
> As you would have LPI only on the Rx path this should be transparent to
> the MAC. That's my understanding. Maybe people knowing EEE better than
> me could confirm (or not) ? Peppe? Alexandre?

EEE is a MAC and PHY feature, and both need to agree on what is enabled,
especially in the transmit path because the way packets may be
transmitted with or without EEE can be done differently at the HW level
(faster/slower return to idle, different clock source).

> 
> I just checked with the OdroidC2, I disabled eee support by forcing
> "dma_cap.eee = 0" in stmmac_get_hw_features. As expected, no tx_LPI
> interrupts but plenty of rx_LPI interrupts.
> 
> What was not expected is test failing like before.
> So in our case, having LPI on the Rx path is fine for receiving data,
> but not for sending.

OK, which really sounds like a potential interoperability problem, or
just the Realtek PHY with EEE enabled acting funky (irrespective of
being attached to stmmac).
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
