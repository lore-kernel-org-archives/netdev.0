From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net v2 2/3] dt: bindings: add ethernet phy
 eee-disable-advert option documentation
Date: Mon, 21 Nov 2016 21:35:34 -0800
Message-ID: <e792c889-8725-3952-ca28-a08537d9f87a@gmail.com>
References: <1479742524-30222-1-git-send-email-jbrunet@baylibre.com>
 <1479742524-30222-3-git-send-email-jbrunet@baylibre.com>
 <20161121160149.GF1922@lunn.ch> <1479744993.17538.85.camel@baylibre.com>
 <20161121164733.GG1922@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Kevin Hilman <khilman@baylibre.com>,
        linux-kernel@vger.kernel.org, Andre Roth <neolynx@gmail.com>,
        linux-amlogic@lists.infradead.org, Carlo Caione <carlo@caione.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>, Jerome Brunet <jbrunet@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161121164733.GG1922@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 21/11/2016 à 08:47, Andrew Lunn a écrit :
>> What I did not realize when doing this patch for the realtek driver is
>> that there is already 6 valid modes defined in the kernel
>>
>> #define MDIO_EEE_100TX		MDIO_AN_EEE_ADV_100TX	/*
>> 100TX EEE cap */
>> #define MDIO_EEE_1000T		MDIO_AN_EEE_ADV_1000T	/*
>> 1000T EEE cap */
>> #define MDIO_EEE_10GT		0x0008	/* 10GT EEE cap */
>> #define MDIO_EEE_1000KX		0x0010	/* 1000KX EEE cap
>> */
>> #define MDIO_EEE_10GKX4		0x0020	/* 10G KX4 EEE cap
>> */
>> #define MDIO_EEE_10GKR		0x0040	/* 10G KR EEE cap
>> */
>>
>> I took care of only 2 in the case of realtek.c since it only support
>> MDIO_EEE_100TX and MDIO_EEE_1000T.
>>
>> Defining a property for each is certainly doable but it does not look
>> very nice either. If it extends in the future, it will get even more
>> messier, especially if you want to disable everything.
> 
> Yes, agreed.

One risk with the definition a group of advertisement capabilities
(under the form of a bitmask for instance) to enable/disable is that we
end up with Device Tree contain some kind of configuration policy as
opposed to just flagging particular hardware features as broken.

Fortunately, there does not seem to be a ton of PHYs out there which
require EEE to be disabled to function properly so having individual
properties vs. bitmasks/groups is kind of speculative here.

Another approach to solving this problem could be to register a PHY
fixup which disables EEE at the PHY level, and which is only called for
specific boards affected by this problem (of_machine_is_compatible()).
This code can leave in arch/*/* when that is possible, or it can just be
somewhere where it is relevant, e.g; in the PHY driver for instance
(similarly to how PCI fixups are done).
-- 
Florian
