From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Wed, 17 Jun 2015 09:26:05 +0200
Message-ID: <5581210D.5070901@6wind.com>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>	<557DCD0A.5040500@hartkopp.net>	<557DD20E.4080005@hartkopp.net>	<557E7D89.30301@6wind.com>	<557E9728.7080208@6wind.com> <20150615085410.6628b5bb@urahara> <55805E6A.90805@hartkopp.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38563 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbbFQH0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 03:26:08 -0400
Received: by wibdq8 with SMTP id dq8so42687343wib.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 00:26:07 -0700 (PDT)
In-Reply-To: <55805E6A.90805@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/06/2015 19:35, Oliver Hartkopp a =E9crit :
> On 15.06.2015 17:54, Stephen Hemminger wrote:
>> On Mon, 15 Jun 2015 11:13:12 +0200
>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>
>>> Theoretically, virtual interfaces should advertise an IFLA_LINK to =
0.
>>> I don't know what is the best fix:
>>>    - patching iproute2 to avoid this '@NONE'
>>>    - patching the kernel (see below).
>>
>>
>> Sorry this is an ABI change. The kernel has to go back
>> to doing the same thing as before.
>>
>
> Isn't this too late right now at 4.1-rc8 stage???
>
> At least the patch suggested for br_device.c at
>
> http://marc.info/?l=3Dlinux-netdev&m=3D143435960111768&w=3D2
>
> would been necessary in all networking drivers, right?
>
> I currently see this @NONE stuff with virtual CAN devices too.
Another solution is to revert e1622baf54df ("dev: set iflink to 0 for v=
irtual
interfaces") and add a ndo_get_iflink handler which returns 0 for all v=
irtual
interfaces that had this IFLA_LINK set to 0 before the series.
But it's not consistent between virtual interfaces.
