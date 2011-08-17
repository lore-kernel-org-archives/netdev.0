From: David Martin <david.martin.mailbox@googlemail.com>
Subject: Re: Influencing triggering of xfrm acquire messages?
Date: Wed, 17 Aug 2011 12:21:15 +0200
Message-ID: <CAGsyNe2770am88um7W+tw=o0Hxnd0KiR7xfJs0+h_XM6o3XHCg@mail.gmail.com>
References: <CAGsyNe2oAkT+idnC-fuOoULTdEubbL8CabLesacjp=2tPiWVmA@mail.gmail.com>
	<20110811.073645.142128983331087817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35473 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab1HQKVS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 06:21:18 -0400
Received: by bke11 with SMTP id 11so573058bke.19
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2011 03:21:16 -0700 (PDT)
In-Reply-To: <20110811.073645.142128983331087817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Aug 11, 2011 at 4:36 PM, David Miller <davem@davemloft.net> wro=
te:
> From: David Martin <david.martin.mailbox@googlemail.com>
> Date: Thu, 11 Aug 2011 16:21:07 +0200
>
>> As long as it exists no additional acquire will be triggered which i=
s a problem,
>> for example when shortly after an exchange the daemon is restarted a=
nd needs to
>> start another exchange with the same peer host.
>>
>> Is this state supposed to be set up? Is it supposed to be removed au=
tomatically
>> once we set up our own SA? Is there a way to remove it manually to
>> trigger another acquire? Any input is welcome, thanks a lot in advan=
ce.
>
> The usage model is that the IPSEC daemon, like a routing daemon, mana=
ges
> all IPSEC state. =A0And therefore it flushes all IPSEC state when it =
starts
> up.
>
> If you want the acquire messages, you need to flush the entries for w=
hich
> you want the acquire to trigger when you startup.

thanks for your reply, that sounds reasonable. The problem is this
specific state I
mentioned (see below).

> martin@pisa1:~$ sudo ip xfrm state
> src 2001:1a:a148:104c:92bb:671e:8100:9354 dst 2001:1c:5000:45b6:2d33:=
2c10:2726:a043
>   proto 0 reqid 0 mode transport
>   replay-window 0
>   sel src 2001:1a:a148:104c:92bb:671e:8100:9354/128 dst 2001:1c:5000:=
45b6:2d33:2c10:2726:a043/128 proto udp sport 49024 dport 1025

It is not set up explicitly by us but on its own when the acquire is tr=
iggered.
We already take care of "our" states and flush them on exit / startup s=
o that
they do not prohibit another acquire. This one though remains for a cer=
tain
time and the question is: how can I remove it? Which parameters do I ne=
ed
to pass to the xfrm interface to flush it?

It does not seem to be possible with the iproute2 implementation
('ip xfrm state delete ...') as it requires a protocol in
{esp | ah | comp | route2 | hao} to delete a state. proto 0 as it is he=
re is not
supported and refused as invalid. I have tried to adapt our code and se=
nd
a delete request with protocol, spi and ports set to 0 but this does no=
t have
the desired effect.

Any idea how to tackle this?

David
