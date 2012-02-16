From: Sameer Nanda <snanda@chromium.org>
Subject: Re: [PATCH 1/2] r8169: Enable WOL from Magic Packet by default
Date: Thu, 16 Feb 2012 12:47:00 -0800
Message-ID: <CANMivWbccWrz=bVhKA8=yDj+RVURiUNFZZpQTix0oD6Ld7+4Gw@mail.gmail.com>
References: <1329244079-27842-1-git-send-email-snanda@chromium.org>
 <20120215001342.GA11453@electric-eye.fr.zoreil.com> <CANMivWax5jGNJLkjZWi2F5iaM+bnK0Ti1qZzQx4CGgkzeQqt7Q@mail.gmail.com>
 <20120214.223746.419009242484406948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, rjw@sisk.pl, hayeswang@realtek.com,
	netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:62564 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884Ab2BPUrV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 15:47:21 -0500
Received: by qafk1 with SMTP id k1so2834774qaf.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 12:47:20 -0800 (PST)
In-Reply-To: <20120214.223746.419009242484406948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 7:37 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Sameer Nanda <snanda@chromium.org>
> Date: Tue, 14 Feb 2012 17:00:04 -0800
>
>> On Tue, Feb 14, 2012 at 4:13 PM, Francois Romieu <romieu@fr.zoreil.c=
om> wrote:
>>> Sameer Nanda <snanda@chromium.org> :
>>>> Set the WOL config registers to only enable WOL from magic packet =
by
>>>> default. Without this change in place, the WOL config register
>>>> settings on warm reboot come up in an inconsistent state since the=
se
>>>> registers don't get reset on a warm reboot.
>>>
>>> I am not completely convinced, especially as the change of behavior
>>> could be noticed.
>>
>> Agreed that this change could be noticed. =C2=A0Maybe a module param=
eter
>> might be a better way to handle this?
>
> Please no random module parameters, something ethtool based is
> what you should shoot for.

With the existing code, WOL from PHY, unicast, multicast and broadcast
packets may get accidentally enabled.  The probability of seeing such
packets/events in the wild is quite high and this can cause unintended
wakes from S3 or reboots.

The probability of seeing matching MagicPackets in the wild is
vanishingly small.  Therefore, setting MagicPacket as the only default
WOL mechanism seems like the safer option.

Since ethtool already supports setting of WOL options from userland, I
guess we don't need a new module parameter as the user can set WOL
options according to his own desires.

--=20
Sameer
