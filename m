From: Kevin Wilson <wkevils@gmail.com>
Subject: Re: GSO and IPv4 forwarding
Date: Tue, 26 Oct 2010 22:26:07 +0200
Message-ID: <AANLkTik+s4CHgPuY6uhe-0aD=WJs=UHhoEdok4AyTdYJ@mail.gmail.com>
References: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
	<1288124114.2652.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:33470 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755634Ab0JZU0I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:26:08 -0400
Received: by iwn10 with SMTP id 10so2572658iwn.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:26:07 -0700 (PDT)
In-Reply-To: <1288124114.2652.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Thanks a lot for your quick answer, I appreciate it (and did not
expect it to be so quick!)

Can someone please explain in 2-3 short sentences Why GRO can be
forwarded and LRO cannot be forwarded ?
rgs,
Kevin

On Tue, Oct 26, 2010 at 10:15 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 26 octobre 2010 =E0 22:02 +0200, Kevin Wilson a =E9crit :
>> Hi,
>> When we set a netdevice to support forwarding, we disable LRO.
>> This is done because we don't want to forward an SKB which has been
>> processed by LRO.
>>
>> This is done in inet_forward_change() in net/ipv4/devinet.c:
>> We call dev_disable_lro(dev) in this method, when setting forwarding
>> for the device.
>> As a result, in ip_forward(), the packet will be dropped. (because
>> skb_warn_if_lro(), called by this method, =A0returns TRUE)
>>
>> My question is:
>> dev_disable_lro(dev) disable the LRO feature (NETIF_F_LRO) of the
>> device. But suppose I have a device where GRO is enabled (and LRO is
>> not). And let's say I set forwarding on this device.
>>
>> it seems to me that is such case, calling dev_disable_lro(dev) =A0in
>> net_forward_change() to disable the LRO feature of the device (which
>> is already disabled) is not enough, and in such case , GRO packets,
>> which want to be forwarded, =A0will **not** be dropped in ip_forward=
().
>> (since kb_warn_if_lro() will return false in this case)
>>
>> Is it so ? I am ready to send a patch fixing it, but I am a newbie i=
n
>> kernel, so I want to ask first.
>
> GRO packets can be forwarded just fine.
>
>
>
>
