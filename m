From: Maxim Uvarov <muvarov@gmail.com>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Mon, 11 Sep 2017 10:53:42 +0300
Message-ID: <CAJGZr0+tqucicpX24Ek7fkUkc2ia=+ucPVVPWS1Gbb65uxOJtQ@mail.gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <8e4aa981-7f41-047d-2101-370118b4f2c0@gmail.com> <CAJGZr0Kp5ZKmFJT+KX9jxMVyZT9=VO0_dpZqE+y1TNaYvURcoQ@mail.gmail.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121EF7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Lunn <andrew@lunn.ch>, Pavel Machek <pavel@ucw.cz>,
        Nathan Conrad <nathan.leigh.conrad@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com, Florian Fainelli <f.fainelli@gmail.com>
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121EF7@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-09-08 22:48 GMT+03:00  <Tristram.Ha@microchip.com>:
>> -----Original Message-----
>> From: Maxim Uvarov [mailto:muvarov@gmail.com]
>> Sent: Friday, September 08, 2017 12:00 PM
>> To: Florian Fainelli
>> Cc: Tristram Ha - C24268; Andrew Lunn; Pavel Machek; Nathan Conrad; Vivien
>> Didelot; netdev; linux-kernel@vger.kernel.org; Woojung Huh - C21699
>> Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
>> drivers can be added
>>
>> 2017-09-08 21:48 GMT+03:00 Florian Fainelli <f.fainelli@gmail.com>:
>> > On 09/07/2017 02:11 PM, Tristram.Ha@microchip.com wrote:
>> >> From: Tristram Ha <Tristram.Ha@microchip.com>
>> >>
>> >> Add other KSZ switches support so that patch check does not complain.
>> >>
>> >> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
>> >> ---
>> >>  Documentation/devicetree/bindings/net/dsa/ksz.txt | 117
>> >> ++++++++++++----------
>> >>  1 file changed, 62 insertions(+), 55 deletions(-)
>> >>
>> >> diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt
>> >> b/Documentation/devicetree/bindings/net/dsa/ksz.txt
>> >> index 0ab8b39..34af0e0 100644
>> >> --- a/Documentation/devicetree/bindings/net/dsa/ksz.txt
>> >> +++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
>> >> @@ -3,8 +3,15 @@ Microchip KSZ Series Ethernet switches
>> >>
>> >>  Required properties:
>> >>
>> >> -- compatible: For external switch chips, compatible string must be
>> >> exactly one
>> >> -  of: "microchip,ksz9477"
>> >> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
>> >> +           "microchip,ksz8795" for KSZ8795 chip,
>> >> +           "microchip,ksz8794" for KSZ8794 chip,
>> >> +           "microchip,ksz8765" for KSZ8765 chip,
>> >> +           "microchip,ksz8895" for KSZ8895 chip,
>> >> +           "microchip,ksz8864" for KSZ8864 chip,
>> >> +           "microchip,ksz8873" for KSZ8873 chip,
>> >> +           "microchip,ksz8863" for KSZ8863 chip,
>> >> +           "microchip,ksz8463" for KSZ8463 chip
>> >
>>
>>
>> Tristram, does any of this devices support chaining?
>>
>> Maxim.
>
> They do not if you mean daisy-chaining the switches together.
>
> There is always a problem that once tail tagging mode is enabled
> sending a frame through the MAC without going through the DSA
> layer will cause the frame to be dropped.
>

Tistram, as Florian answered before  by "chaining"  in my question I
meant milti chip DSA.
I.e. when several chips represent one DSA instance and all interfaces
joined to  the same bridge.
Bridge code take care about fdb, mdb, vlan configuration for all
chips. If packet supposed to be
forward across chips it will not go to cpu, Only cpus related traffic
goes to cpu (like broad casts,
fdb mac entry, unknown packet, stp/BPDU). I.e. milti chip DSA allows
you to work with several chips
as one big virtual chip. How to make it happen depends on hardware
possibilities.  Might be several
tail tags, but in that case other chips have to know how to work with
it. Or smart vlans configuration,
but it that case cross chip vlan should not overlap with system vlans.
In marvel it's done that each tag
has chip id which can be programmed from mdio, and also each chip
knows how to work with that tag
and their place in dsa chain - "up-link" and "down-link". For ksz* I
did not find any notes that such configuration
is supported. How ever it might be doable with some smart software settings.

-- 
Best regards,
Maxim Uvarov
