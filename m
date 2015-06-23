From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Tue, 23 Jun 2015 14:48:32 +0200
Message-ID: <558955A0.7040203@6wind.com>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>	<557DCD0A.5040500@hartkopp.net>	<557DD20E.4080005@hartkopp.net>	<557E7D89.30301@6wind.com>	<557E9728.7080208@6wind.com> <20150615085410.6628b5bb@urahara> <55805E6A.90805@hartkopp.net> <5581210D.5070901@6wind.com> <5585F005.6060408@hartkopp.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37399 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbbFWMsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 08:48:35 -0400
Received: by wicgi11 with SMTP id gi11so15650858wic.0
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 05:48:34 -0700 (PDT)
In-Reply-To: <5585F005.6060408@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/06/2015 00:58, Oliver Hartkopp a =E9crit :
>
>
> On 06/17/2015 09:26 AM, Nicolas Dichtel wrote:
>> Le 16/06/2015 19:35, Oliver Hartkopp a =E9crit :
>>> On 15.06.2015 17:54, Stephen Hemminger wrote:
>>>> On Mon, 15 Jun 2015 11:13:12 +0200
>>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>>>
>>>>> Theoretically, virtual interfaces should advertise an IFLA_LINK t=
o 0.
>>>>> I don't know what is the best fix:
>>>>>     - patching iproute2 to avoid this '@NONE'
>>>>>     - patching the kernel (see below).
>>>>
>>>>
>>>> Sorry this is an ABI change. The kernel has to go back
>>>> to doing the same thing as before.
>>>>
>>>
>>> Isn't this too late right now at 4.1-rc8 stage???
>>>
>>> At least the patch suggested for br_device.c at
>>>
>>> http://marc.info/?l=3Dlinux-netdev&m=3D143435960111768&w=3D2
>>>
>>> would been necessary in all networking drivers, right?
>>>
>>> I currently see this @NONE stuff with virtual CAN devices too.
>> Another solution is to revert e1622baf54df ("dev: set iflink to 0 fo=
r virtual
>> interfaces") and add a ndo_get_iflink handler which returns 0 for al=
l virtual
>> interfaces that had this IFLA_LINK set to 0 before the series.
>> But it's not consistent between virtual interfaces.
>
> I have no good suggestion, as I don't know if this makes a difference=
 for the
> ABI to finally make 'ip' omit the '@NONE' output.
>
> E.g. virtual CAN interfaces (vcan.c) now print this @NONE and they ne=
ver have
> a (physical?) link. So you probably have to deal with different virtu=
al
> interfaces anyway, right?
Yes, with the current code, all virtual interfaces (that define a
rtnl_link_ops) will have this "@SOMETHING" because IFLA_LINK is now set=
 to 0.
The initial goal of iflink was to be able to identify virtual interface=
s vs
physical one. But this was not consistent between virtual interfaces.
If it is required to go back to the previous state, I think the best so=
lution
would be the one explained above (revert e1622baf54df + add ndo_get_ifl=
ink()
where needed).

David, what is your opinion?

Regards,
Nicolas
