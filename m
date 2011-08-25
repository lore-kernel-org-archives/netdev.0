From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: Re: Traffic shaping - class ID 16bit limit?
Date: Thu, 25 Aug 2011 19:06:58 +0200
Message-ID: <CAO0uZ+_6xC0gymfbu28PRK4SaVgkGaSbbe-PgXvZ4h-cPp8k2A@mail.gmail.com>
References: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
	<20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:52902 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab1HYRG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 13:06:59 -0400
Received: by gya6 with SMTP id 6so1920056gya.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 10:06:58 -0700 (PDT)
In-Reply-To: <20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Technically the ClassID seems to be "hardcoded" as a 16bit value, but
>> after some source searching, I haven't found any good reason for it to
>> be 16-bit only.
>
> Granted it was a poor choice in the initial design.
> It is wired into the API and changing it would be quite painful.
>

I was feeling something like that would come.

If I get it correctly, the API change would consist of:

- some netlink protocol change
- slight modification of qdisc_class_hash
- modifications in all (four?) hierarchical schedulers
- tiny expansion of userspace tc utility

which isn't that painful (except for the CBQ part), but I'm probably
missing something, and presumably the change would take some time to
get mainstream -- probably way more time than writing a hfsc clone
that is controlled using some other interface than tc/netlink. :(

(but hey! I have a topic for school work!)

> You might be able to do the same thing by splitting traffic
> into multiple virtual devices (dummy or ifb) and then doing
> another layer.
>

My scenario looks pretty simple, mostly like a big hashing filter
attached at the device root, flowid'ing the stuff to leaf classes.
Could you please provide some simple illustration of splitting that
into multiple devices? I guess that the main problem with this
approach would be that my subclasses usually don't share anything in
common, especially not any pretty IP prefixes that would allow good
splitting.

Anyway, thanks very much for response!

-mk
