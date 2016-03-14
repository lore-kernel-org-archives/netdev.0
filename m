From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Mon, 14 Mar 2016 10:57:01 -0700
Message-ID: <CAF2d9jgqAqUxN0HSTUguQyf6m62wDWizTH4bQ+Hz1xxte-=kaQ@mail.gmail.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
 <20160313.215033.17951850162749485.davem@davemloft.net> <CAF2d9jhtvvEdmwP8OrOcUEn+P-Di0TRnjR7-RpcJrKJ3+HAN-Q@mail.gmail.com>
 <20160313.235358.1007563444789525672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mahesh@bandewar.net, Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:33460 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801AbcCNR5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:57:22 -0400
Received: by mail-yw0-f181.google.com with SMTP id d65so177529968ywb.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 10:57:21 -0700 (PDT)
In-Reply-To: <20160313.235358.1007563444789525672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 8:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Sun, 13 Mar 2016 19:29:58 -0700
>
>> On Sun, Mar 13, 2016 at 6:50 PM, David Miller <davem@davemloft.net> wrote:
>>> It doesn't matter whether doing so or not makes sense.
>>>
>>> You're going to have to find a way to do both, and also I'm concerned
>>> about how you're leaking the source namespace's "stuff" into the
>>> destination's.  That's very worrisome to me.
>>
>> If we add a new mode (e.g. L3s) and preserve current mode as is it,
>> then that should address your first concern.
>
> Also, I don't want all of this device translation stuff all over the
> place.
>
I could add skb->dev. Is that OK? Then non of this translation / helper-stuff
is required. I'm definitely open for suggestions.

> Furthermore, when you walk across the ns boundary, that old device has
> to disappear.  That's why that is the device assigned to skb->dev.
>
The layer boundaries are not that well maintained. We do check for the xfrm
policies in L4 and expect the skb->dev pointing to the L3 device. So unless we
have a way to derive a L3 dev from skb->dev, I don't think xfrm will
work. Unless
some Xfrm-expert asserts that this is not needed.

> Please stop pretending that this device switching is ok, it's not.
