From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sun, 27 Apr 2014 21:22:33 -0700
Message-ID: <CA+mtBx9OHBU-k_TGr=SHDWREE6v+6tYpGgk0m8iFwZW5YmHrHg@mail.gmail.com>
References: <CA+mtBx-hAJDvXigrw1w3S1OBhmG4iiZvBBKNtCXZMt+8ZzFduw@mail.gmail.com>
	<20140427.233204.1660487737838648405.davem@davemloft.net>
	<CA+mtBx9w6-id5NDuP31yMrhO9Ho8TM2O5oGfneXiT_f+G+Xvag@mail.gmail.com>
	<20140428.001552.1083601553706782584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:56897 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbaD1EWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 00:22:34 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so4350762igb.5
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 21:22:33 -0700 (PDT)
In-Reply-To: <20140428.001552.1083601553706782584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2014 at 9:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 27 Apr 2014 21:07:24 -0700
>
>>> If we do anything, we should do it consistently and not just for one
>>> specific checksum delivery type.
>>>
>>> So if we add a sysctl, it should revalidate the checksum in software
>>> for all checksum offload variants, and such a sysctl should be off by
>>> default.
>>
>> Okay, but I would want to add a new checksum type to distinguish
>> checksum_complete that was done in software as opposed to one received
>> from a device.
>
> I don't think it's wise to keep CHECKSUM_COMPLETE once you've software
> verified it.
>
> If anything, you should at that point treat it as we would have treated
> it were it marked CHECKSUM_NONE.
>
We want to keep it if there are multiple checksums in the packet which
is possible with encapsulation. It really shouldn't add any cost to
maintain it with the packet.
