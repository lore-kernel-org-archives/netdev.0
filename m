From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC 2/2] e1000e: Support RXALL feature flag.
Date: Wed, 8 Feb 2012 10:31:50 +0100
Message-ID: <CAHXqBFJcPE1btvDFES-7a+i5PgwZjJ3CQHx6S7wvQKuk2zPtGQ@mail.gmail.com>
References: <1328656063-13129-1-git-send-email-greearb@candelatech.com>
 <1328656063-13129-2-git-send-email-greearb@candelatech.com>
 <CAHXqBFJ9=fXYuzZd0SM0hGsDxQee5UPzOwThbxNkks03VLFunw@mail.gmail.com> <4F31BF75.4090304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42241 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab2BHJcM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 04:32:12 -0500
Received: by ghrr11 with SMTP id r11so94558ghr.19
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2012 01:32:12 -0800 (PST)
In-Reply-To: <4F31BF75.4090304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 8 lutego 2012 01:19 u=BFytkownik Ben Greear
<greearb@candelatech.com> napisa=B3:
> On 02/07/2012 04:06 PM, Micha=B3 Miros=B3aw wrote:
>> 2012/2/8<greearb@candelatech.com>:
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> This allows the NIC to receive all frames available, including
>>> those with bad FCS, un-matched vlans, ethernet control frames,
>>> and more.
>>>
>>> Tested by sending frames with bad FCS.
>> This should probably mark the bad packets somehow, so they are not
>> passed up the stack and mixed with correct traffic.
> Anything that does higher-level checksumming should figure out the
> problem, if it's real (ie, if not *just* a corrupted FCS). =A0Anythin=
g
> that doesn't is open to abuse by something sending corrupted packets
> with correct checksums anyway.
>
> But, if you think it's really needed, I could add a flag to the skb a=
nd
> then free the skb after the ptype_all logic in netif_receive_skb
> has been called?

Hmm. Passing of possibly corrupted packets might be useful for
UDPlite, but for other IP protocols CRC32 is stronger than IP checksum
and ignoring the former would allow more silently broken packets to
pass through.

I'm not convinced either way, though - just opening a discussion, as
this might change the assumptions on IP over Ethernet people make in
their apps.

When IP checksum (incl. TCP/UDP) is ok and FCS is bad, then we have a
few possibilities:
 1. only some bits in FCS are bad,
 2. some 2 matching bits of IP/TCP/UDP checksum and payload are flipped=
,
 3. a lot of bits (at least 16) in packet's data or header are bad,
 4. some other corruption.

Best Regards,
Micha=B3 Miros=B3aw
