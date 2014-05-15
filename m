From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 2/2] net: systemport: pad packets to a minimum
 of 68 bytes
Date: Thu, 15 May 2014 09:45:04 -0700
Message-ID: <CAGVrzcZq=GEyBG47xphCi5EVDs64xjYkAZjLiefJkewVDb1jJQ@mail.gmail.com>
References: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
 <1400121134-6088-3-git-send-email-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D17246361@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:64528 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaEOQpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 12:45:45 -0400
Received: by mail-qg0-f46.google.com with SMTP id q108so2173504qgd.33
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 09:45:45 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17246361@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-15 2:28 GMT-07:00 David Laight <David.Laight@aculab.com>:
> From: Florian Fainelli
>> With packets having Broadcom tags, the 4-bytes tag is first stripped
>> off the packet, and the packet length is then checked, so we need to
>> make sure that the packet length with FCS is at least 64 bytes.
>
> Ah - finally an explanation!
>
> I think you should only do that when the Broadcom Tags are enabled.

I thought about that, and could not make my mind about doing something like:

min_pad_len = ETH_ZLEN;
if (netdev_uses_brcm_tag(dev))
           min_pad_len += ENET_BRCM_TAG_LEN;

or doing the padding unconditionally like this.

The switch driver has been submitted for review on netdev, and that
includes the netdev_uses_brcm_tag() helper function to tell us whether
Broadcom tags are enabled or not on that particular interface.

One of the argument that I have against that, is that it makes our
driver a little more special, and that would make it the only one (for
now at least). I sort of wanted the fix to be independent from
eventually other non-DSA switch implementations.
-- 
Florian
