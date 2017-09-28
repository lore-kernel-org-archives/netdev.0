From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Thu, 28 Sep 2017 11:45:11 -0700
Message-ID: <329de4cb-f06a-89b7-3cbd-e67493ffb067@gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928184059.GA2825@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Pavel Machek <pavel@ucw.cz>, Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928184059.GA2825@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 11:40 AM, Pavel Machek wrote:
> Hi!
> 
> On Mon 2017-09-18 20:27:13, Tristram.Ha@microchip.com wrote:
>>>> +/**
>>>> + * Some counters do not need to be read too often because they are less
>>> likely
>>>> + * to increase much.
>>>> + */
>>>
>>> What does comment mean? Are you caching statistics, and updating
>>> different values at different rates?
>>>
>>
>> There are 34 counters.  In normal case using generic bus I/O or PCI to read them
>> is very quick, but the switch is mostly accessed using SPI, or even I2C.  As the SPI
>> access is very slow and cannot run in interrupt context I keep worrying reading
>> the MIB counters in a loop for 5 or more ports will prevent other critical hardware
>> access from executing soon enough.  These accesses can be getting 1588 PTP
>> timestamps and opening/closing ports.  (RSTP Conformance Test sends test traffic
>> to port supposed to be closed/opened after receiving specific RSTP
>> BPDU.)
> 
> Hmm. Ok, interesting.
> 
> I wonder how well this is going to work if userspace actively 'does
> something' with the switch.
> 
> It seems to me that even if your statistics code is careful not to do
> 'a lot' of accesses at the same time, userspace can use other parts of
> the driver to do the same, and thus cause same unwanted effects...

A few switches have a MIB snapshot feature that is implemented such that
accessing the snapshot does not hog the remainder of the switch
registers, is this something possible on KSZ switches?

Tangential: net-next is currently open, so now would be a good time to
send a revised version of your patch series to target possibly 4.15 with
an initial implementation. Please fix the cover-letter and patch
threading such that they look like the following:

[PATCH 0/X]
   [PATCH 1/X]
   [PATCH 2/X]
   etc..

Right now this shows up as separate emails/patches and this is very
annoying to follow as a thread.

Thank you
-- 
Florian
