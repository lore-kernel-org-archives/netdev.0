From: Romain Perier <romain.perier@gmail.com>
Subject: Re: [PATCH v2] ethernet: arc: Add support for specific SoC glue layer
 device tree bindings
Date: Tue, 19 Aug 2014 08:50:20 +0200
Message-ID: <53F2F3AC.3060102@gmail.com>
References: <1408286882-10186-1-git-send-email-romain.perier@gmail.com> <53F2580D.60908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: heiko@sntech.de, tklauser@distanz.ch, b.galvani@gmail.com,
	eric.dumazet@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:48003 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaHSGs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 02:48:26 -0400
Received: by mail-wi0-f180.google.com with SMTP id n3so4761450wiv.13
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2014 23:48:25 -0700 (PDT)
In-Reply-To: <53F2580D.60908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/08/2014 21:46, Florian Fainelli a =C3=A9crit :
> On 08/17/2014 07:48 AM, Romain Perier wrote:
>> Some platforms have special bank registers which might be used to se=
lect
>> the correct clock or the right mode for Media Indepent Interface con=
trollers.
>> Sometimes, it is also required to activate vcc regulators in the rig=
ht order to supply
>> the ethernet controller at the right time. This patch is a refactori=
ng of the arc-emac
>> device driver, it adds a new software architecture design which allo=
ws to add specific
>> platform glue layer. Each platform has now its own module which perf=
orms custom initialization
>> and remove for the target and then calls to the core driver.
> Most of the changes are made largely harder to read because you renam=
ed
> a struct device pointer variable, so what I would suggest you do is:
>
> - use the same struct device pointer variable throughout
> arc_emac_probe() as a preliminary change, that will be easier to read
>
> - allow for specifying custom platform data and make this intermediat=
e
> struct device pointer variable point to the newly added struct device
> pointer (which would make the changes much less intrusive)
>
> Thanks!
Hi,

so, you suggest two seperated commits, right ? The first one with the=20
first item and the second one
with the second item, right ?

Romain


>
>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
>> ---
>>   drivers/net/ethernet/arc/Kconfig     |  13 ++--
>>   drivers/net/ethernet/arc/Makefile    |   3 +-
>>   drivers/net/ethernet/arc/emac.h      |  21 ++++-
>>   drivers/net/ethernet/arc/emac_arc.c  |  77 +++++++++++++++++++
>>   drivers/net/ethernet/arc/emac_main.c | 145 +++++++++++++++--------=
------------
>>   drivers/net/ethernet/arc/emac_mdio.c |  11 ++-
>>   6 files changed, 170 insertions(+), 100 deletions(-)
>>   create mode 100644 drivers/net/ethernet/arc/emac_arc.c
>>
>> diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet=
/arc/Kconfig
>> index 514c57f..ecaff9c 100644
>> --- a/drivers/net/ethernet/arc/Kconfig
>> +++ b/drivers/net/ethernet/arc/Kconfig
>> @@ -3,8 +3,11 @@
>>   #
>>  =20
>>   config NET_VENDOR_ARC
>> -	bool "ARC devices"
>> -	default y
>> +	tristate "ARC devices"
>> +	select MII
>> +	select PHYLIB
>> +	depends on OF_IRQ
>> +	depends on OF_NET
> NET_VENDOR_ARC is a Kconfig symbol that should remain default y, it i=
s
> just there such that there is a submenu for all ARC devices, if you n=
eed
> to factor some Kconfig options into a generic place, you should proba=
bly
> introduce a new Kconfig option such as ARC_EMAC_GLUE or something lik=
e that.
>
>>   	---help---
>>   	  If you have a network (Ethernet) card belonging to this class, =
say Y
>>   	  and read the Ethernet-HOWTO, available from
>> @@ -18,11 +21,7 @@ config NET_VENDOR_ARC
>>   if NET_VENDOR_ARC
>>  =20
>>   config ARC_EMAC
>> -	tristate "ARC EMAC support"
>> -	select MII
>> -	select PHYLIB
>> -	depends on OF_IRQ
>> -	depends on OF_NET
>> +	tristate "ARC EMAC support
>>   	---help---
>>   	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML5=
0x
>>   	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
>> diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/etherne=
t/arc/Makefile
> --
> Florian
