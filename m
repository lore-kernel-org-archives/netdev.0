From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging operations
Date: Thu, 19 Feb 2015 23:58:50 -0500
Message-ID: <CAE4R7bA7m=_bYc6aZRiGQVG22wTOS0_+Mt2OT2P7tvh1r45AYg@mail.gmail.com>
References: <20150219055953.GA14247@roeck-us.net>
	<54E61CFB.3010109@gmail.com>
	<20150219174640.GA6897@roeck-us.net>
	<54E676DD.9090003@gmail.com>
	<20150220000935.GA30118@roeck-us.net>
	<54E68512.6070108@cumulusnetworks.com>
	<20150220010352.GA300@roeck-us.net>
	<54E691F2.5090205@cumulusnetworks.com>
	<54E69536.3040303@gmail.com>
	<54E69EDE.2030307@cumulusnetworks.com>
	<20150220040559.GB5017@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35888 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbbBTE6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 23:58:51 -0500
Received: by mail-qg0-f44.google.com with SMTP id j5so11996496qga.3
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 20:58:50 -0800 (PST)
In-Reply-To: <20150220040559.GB5017@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 11:05 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> On Thu, Feb 19, 2015 at 06:41:34PM -0800, roopa wrote:
>> On 2/19/15, 6:00 PM, Florian Fainelli wrote:
>> >On 19/02/15 17:46, roopa wrote:
>> >>On 2/19/15, 5:03 PM, Guenter Roeck wrote:
>> >>>On Thu, Feb 19, 2015 at 04:51:30PM -0800, roopa wrote:
>> >>>>>Not sure yet what to do about setting the fdb aging time. I don't see a
>> >>>>>mechanism to do that. No idea how important that is.
>> >>>>rocker, the only consumer today relies on the bridge driver aging of
>> >>>>learnt
>> >>>>entries.
>> >>>>You could do the same.
>> >>>>
>> >>>Remember that we are dealing with hardware switch chips. Those chips
>> >>>won't time out fdb entries just because the kernel's bridge driver
>> >>>thinks that it should.
>> >>Oh, they dont..?. sorry,  I dont know the details about your hardware.
>> >>But, if these are entries learnt by hw, there should be a hw config to
>> >>age them (I guess that is what you are talking about). Which the swicth
>> >>driver can set.
>> >>If you disable hw aging, you can sync these entries to the bridge
>> >>driver, and make the bridge driver age them followed by a subsequent
>> >>delete in hw.
>> >The SF2 HW has and aging and a valid bit available, I guess my question
>> >would be, do we have anything today in "net-next" that allows
>> >configuring HW aging vs. SW aging (implying doing a HW to SW sync)?
>>
>>
>> There is no config parameter to set HW aging vs SW aging. But if you want SW
>> aging, an example is the rocker implementation today.
>> And there is BR_LEARNING_SYNC per bridge port flag to sync HW to SW using
>> notifiers (see rocker).
>>
> SW aging is not practical. In my specific use case there can be 800+ mac
> addresses in a single mac domain, connected through an mdio bus on gpio pins.
> Besides, it doesn't really make much sense to burden SW with something that
> can easily be handled in HW, just because SW doesn't have the means to pass
> the necessary parameter - aging time - to the HW.

I have a patch which I'll post shortly as an RFC that addresses ageing
either by SW or by HW.

-scott
