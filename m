From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] net: bcmgenet: collect Rx discarded packet count
Date: Wed, 11 Mar 2015 11:17:44 -0700
Message-ID: <CAGVrzcZwGcs1DTTzUXTz3ydX=mmpAoJvEDB_5R9juLUucrzMNQ@mail.gmail.com>
References: <20150310225500.8FA34220365@puck.mtv.corp.google.com>
 <CAGVrzcYNMsCKGdouLULKBb6dtMYviAJR26vO4XTJrh3aYSZC4A@mail.gmail.com> <CAGXr9JHSGtySCs80PfSPBGbWyTXiE3pA0esi=fyCMPKRxmhboA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:32909 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbCKSSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 14:18:25 -0400
Received: by igbhl2 with SMTP id hl2so39298319igb.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 11:18:24 -0700 (PDT)
In-Reply-To: <CAGXr9JHSGtySCs80PfSPBGbWyTXiE3pA0esi=fyCMPKRxmhboA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-11 10:59 GMT-07:00 Petri Gynther <pgynther@google.com>:
> I find the Rx discard counter very useful, as it indicates HW dropped
> packets, which directly affects media playback quality.

I do not question the usefulness of that counter, I am wondering about
whether we could make sure we deal with this counter in a slow/error
path, I guess the answer to my previous question is no, because having
interrupts off for too long does not mean the CPU ran out of memory
for incoming packets.

In  that case, this patch is fine as-is.

>
> In our unit tests, we actually discovered a major interrupts-off
> offender with this. Even with a moderate Rx traffic, we were seeing Rx
> discards. It turned out that using a large dmesg log buffer and
> dumping it with "cat /proc/kmsg" held interrupts off for long enough
> that bcmgenet experienced discards. It was very useful to have the
> discard data available when debugging this.

That is completely fair, it is just that I did a lot of performance
optimization before, and any expensive register in the hot-path is a
big no-no because that impacts your small packet performance (and thus
larger packet performance as well).
-- 
Florian
