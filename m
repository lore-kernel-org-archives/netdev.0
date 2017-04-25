From: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Tue, 25 Apr 2017 11:15:43 -0400
Message-ID: <CAC3K-4qn5oCXvyMCkFESGqMHqHXGiNUW6wfRx2LUZ8qZ39qroQ@mail.gmail.com>
References: <20170424215022.30382-1-eric@anholt.net> <20170424215022.30382-3-eric@anholt.net>
 <f870339f-2fa1-411d-5ce8-adbe8802d8a8@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f870339f-2fa1-411d-5ce8-adbe8802d8a8-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 5:40 AM, Sergei Shtylyov
<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org> wrote:
> Hello.
>
> On 4/25/2017 12:50 AM, Eric Anholt wrote:
>
>> Cygnus has a single amac controller connected to the B53 switch with 2
>> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
>> the external ethernet jacks.
>
>
>    My spell checker trips on "amac" and "ethernet" -- perhaps they need
> capitalization?
>
>> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
>> ---
>>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 60
>> ++++++++++++++++++++++++++++++++++
>>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>>  2 files changed, 68 insertions(+)
>>
>> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi
>> b/arch/arm/boot/dts/bcm-cygnus.dtsi
>> index 009f1346b817..318899df9972 100644
>> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
>> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
>> @@ -142,6 +142,56 @@
>>                         interrupts = <0>;
>>                 };
>>
>> +               mdio: mdio@18002000 {
>> +                       compatible = "brcm,iproc-mdio";
>> +                       reg = <0x18002000 0x8>;
>> +                       #size-cells = <1>;
>> +                       #address-cells = <0>;
>> +
>> +                       gphy0: eth-gphy@0 {
>
>
>    The node anmes must be generic, the DT spec has standardized
> "ethernet-phy" name for this case.
>
>> +                               reg = <0>;
>> +                               max-speed = <1000>;
>> +                       };
>> +
>> +                       gphy1: eth-gphy@1 {
>> +                               reg = <1>;
>> +                               max-speed = <1000>;
>> +                       };
>> +               };
>
> [...]
>>
>> @@ -295,6 +345,16 @@
>>                         status = "disabled";
>>                 };
>>
>> +               eth0: enet@18042000 {
>> +                       compatible = "brcm,amac";
>> +                       reg = <0x18042000 0x1000>,
>> +                             <0x18110000 0x1000>;
>> +                       reg-names = "amac_base", "idm_base";
>
>
>    I don't think "_base" suffixes are necessary here.

100% necessary, per the driver.  See
drivers/net/ethernet/broadcom/bgmac-platform.c


>
> [...]
>
> MBR, Sergei
>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
