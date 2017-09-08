From: Maxim Uvarov <muvarov@gmail.com>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 16:32:35 +0300
Message-ID: <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <20170907215417.GU11248@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tristram.Ha@microchip.com, Pavel Machek <pavel@ucw.cz>,
        Nathan Conrad <nathan.leigh.conrad@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170907215417.GU11248@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-09-08 0:54 GMT+03:00 Andrew Lunn <andrew@lunn.ch>:
>> -- compatible: For external switch chips, compatible string must be exactly one
>> -  of: "microchip,ksz9477"
>> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
>> +           "microchip,ksz8795" for KSZ8795 chip,
>> +           "microchip,ksz8794" for KSZ8794 chip,
>> +           "microchip,ksz8765" for KSZ8765 chip,
>> +           "microchip,ksz8895" for KSZ8895 chip,
>> +           "microchip,ksz8864" for KSZ8864 chip,
>> +           "microchip,ksz8873" for KSZ8873 chip,
>> +           "microchip,ksz8863" for KSZ8863 chip,
>> +           "microchip,ksz8463" for KSZ8463 chip
>

all that chips have the same spi access to get chip id on probe(). I
prefer common microship,ksz-spi rather than somebody will always
maintain that list.

Maxim.

> This part of this patch should be in a patch of the series that
> actually adds support for these chips. Don't document chips until you
> actually support them.
>
>>  See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional  required and optional properties.
>> @@ -13,60 +20,60 @@ Examples:
>>
>>  Ethernet switch connected via SPI to the host, CPU port wired to eth0:
>>
>> -                             eth0: ethernet@10001000 {
>> -                                             fixed-link {
>> -                                                             speed = <1000>;
>> -                                                             full-duplex;
>> -                                             };
>> -                             };
>> +     eth0: ethernet@10001000 {
>> +             fixed-link {
>> +                     speed = <1000>;
>> +                     full-duplex;
>> +             };
>> +     };
>>
>> -                             spi1: spi@f8008000 {
>> -                                             pinctrl-0 = <&pinctrl_spi_ksz>;
>> -                                             cs-gpios = <&pioC 25 0>;
>> -                                             id = <1>;
>> -                                             status = "okay";
>> +     spi1: spi@f8008000 {
>> +             cs-gpios = <&pioC 25 0>;
>> +             id = <1>;
>> +             status = "okay";
>>
>> -                                             ksz9477: ksz9477@0 {
>> -                                                             compatible = "microchip,ksz9477";
>> -                                                             reg = <0>;
>> +             ksz9477: ksz9477@0 {
>> +                     compatible = "microchip,ksz9477";
>> +                     reg = <0>;
>>
>> -                                                             spi-max-frequency = <44000000>;
>> -                                                             spi-cpha;
>> -                                                             spi-cpol;
>> +                     spi-max-frequency = <44000000>;
>> +                     spi-cpha;
>> +                     spi-cpol;
>> +
>> +                     status = "okay";
>> +                     ports {
>> +                             #address-cells = <1>;
>> +                             #size-cells = <0>;
>> +                             port@0 {
>> +                                     reg = <0>;
>> +                                     label = "lan1";
>> +                             };
>> +                             port@1 {
>> +                                     reg = <1>;
>> +                                     label = "lan2";
>> +                             };
>> +                             port@2 {
>> +                                     reg = <2>;
>> +                                     label = "lan3";
>> +                             };
>> +                             port@3 {
>> +                                     reg = <3>;
>> +                                     label = "lan4";
>> +                             };
>> +                             port@4 {
>> +                                     reg = <4>;
>> +                                     label = "lan5";
>> +                             };
>> +                             port@5 {
>> +                                     reg = <5>;
>> +                                     label = "cpu";
>> +                                     ethernet = <&eth0>;
>> +                                     fixed-link {
>> +                                             speed = <1000>;
>> +                                             full-duplex;
>> +                                     };
>> +                             };
>> +                     };
>> +             };
>> +     };
>>
>> -                                                             status = "okay";
>> -                                                             ports {
>> -                                                                             #address-cells = <1>;
>> -                                                                             #size-cells = <0>;
>> -                                                                             port@0 {
>> -                                                                                             reg = <0>;
>> -                                                                                             label = "lan1";
>> -                                                                             };
>> -                                                                             port@1 {
>> -                                                                                             reg = <1>;
>> -                                                                                             label = "lan2";
>> -                                                                             };
>> -                                                                             port@2 {
>> -                                                                                             reg = <2>;
>> -                                                                                             label = "lan3";
>> -                                                                             };
>> -                                                                             port@3 {
>> -                                                                                             reg = <3>;
>> -                                                                                             label = "lan4";
>> -                                                                             };
>> -                                                                             port@4 {
>> -                                                                                             reg = <4>;
>> -                                                                                             label = "lan5";
>> -                                                                             };
>> -                                                                             port@5 {
>> -                                                                                             reg = <5>;
>> -                                                                                             label = "cpu";
>> -                                                                                             ethernet = <&eth0>;
>> -                                                                                             fixed-link {
>> -                                                                                                             speed = <1000>;
>> -                                                                                                             full-duplex;
>> -                                                                                             };
>> -                                                                             };
>> -                                                             };
>> -                                             };
>> -                             };
>
> This part however is a nice cleanup. You can submit this patch as a
> separate patch, once netdev has opened again in about 10 days time.
>
>          Andrew



-- 
Best regards,
Maxim Uvarov
