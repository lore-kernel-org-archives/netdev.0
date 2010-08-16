From: LionSky <loverunning2@gmail.com>
Subject: Re: [Power Efficiency Proposal] Low Power on Media Disconnect
Date: Mon, 16 Aug 2010 15:00:34 +0800
Message-ID: <AANLkTinjinoSNO3OtuVtq=J7CmitjJ-4QeSmFYrtqo=-@mail.gmail.com>
References: <AANLkTin3DNEPDA+vpY-WuSa8ia-sgEA8_sr9qOLpDHph@mail.gmail.com>
	<1281938880.2942.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jie.yang@atheros.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:59418 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab0HPHAf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 03:00:35 -0400
Received: by qyk29 with SMTP id 29so1596873qyk.19
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 00:00:35 -0700 (PDT)
In-Reply-To: <1281938880.2942.68.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric,
Yes, you are right. It is better to handle the ethernet device power
switch from a user policy daemon.
This is just a proposal about Low Power on Media Disconnect which
means when media, such as ethernet cable, is disconnected, the related
device should be placed in a low power state, such as D3hot.
Maybe we needs a smart implementation.

Thanks
-Lionsky

2010/8/16 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 16 ao=FBt 2010 =E0 13:35 +0800, LionSky a =E9crit :
>> It is a very typical scenario that users of laptop/Netbook experienc=
e
>> Internet over wireless instead of ethernet.
>> An obvious hint about that is user unplug-in the ethernet cable whic=
h
>> implies that he does not want to use the ethernet. So for power
>> efficiency, it is best to place ethernet adapter into a low power
>> state, such as C3hot, when ethernet cable is disconnected.
>> Battery life is very important for Laptop/Netbook. Currently, the
>> power consumption of active idle on a typical Netbook is about 5-6
>> Watt. If you placed the etherent adapter in C3hot state, about
>> 0.5~1.0Watt power is saved which depneds on your H/W. This can prolo=
ng
>> battery life about 10%~20% which is a quite big power saving.
>> Now, Linux kernel supports runtime power management. It is not a har=
d
>> work to enable this feature on each ethernet adapter driver.
>>
>> Here I attached a simple and prototype implementation which is
>> verified on a Netbook (ASUS E1005PE with Atheros AR8132 PCI-E Fast
>> Ethernet Controller).
>> 1. When ethernet cable is disconnected, driver places ethernet adapt=
er
>> into D3hot low power state. Just as CPU go to deep C-State.
>> 2. When ethernet cable is connected again, driver places ethernet ba=
ck
>> in D0 power state.
>>
>> To further improve the power behavior of Linux on laptop/Netbook, a
>> proposal is that all ethernet drivers must support Low Power on Medi=
a
>
> =A0... should support ...
>
>> Disconnect.
>>
>> Is it right? Welcome any comments.
>>
>
> I cannot say if this patch is right on the power side.
> (Would it be better to handle the ethernet device power switch from a
> user policy daemon, instead of forcing the policy from the driver ?)
> I dont know the implications of Low Power on Media disconnect.
> At least, let ethtool be able to switch on or off this automatic
> behavior...
>
> But your patch introduces a shared (static actually) variable, atl1c_=
d3.
> Are you sure a single state is enough to handle several ethernet port=
s ?
>
>
>
>
