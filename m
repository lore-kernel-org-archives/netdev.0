From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 25 Jan 2011 10:46:29 +0800
Message-ID: <AANLkTimz7gx7BAQG8RBswDCxnTuVtt3u+YoBZk8+RgEz@mail.gmail.com>
References: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
 <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
 <AANLkTikpu05V92T+YvuHW+jcTH-Bu2t6=HoQn5OR3ZhX@mail.gmail.com>
 <AANLkTinsWVHj6qdSS-_ztztcNPHAkwZQnimPbjzvcHb2@mail.gmail.com> <AANLkTimWuBfeYPOsOFpTiAGS5uHysevAHiOg0svBQ4zW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com, joe@perches.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46585 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab1AYCqu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 21:46:50 -0500
In-Reply-To: <AANLkTimWuBfeYPOsOFpTiAGS5uHysevAHiOg0svBQ4zW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Micha=C5=82,

2011/1/25 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> W dniu 24 stycznia 2011 09:26 u=C5=BCytkownik Po-Yu Chuang
> <ratbert.chuang@gmail.com> napisa=C5=82:
>> 2011/1/21 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
>>> Did you test this? This looks like it will result in double free af=
ter
>>> packet RX, as you are giving the same page (referenced once) to two
>>> distinct RX descriptors, that may be assigned different packets.
>>
>> Yes, this is tested.
>>
>>> Since your not implementing any RX offloads, you might just allocat=
e
>>> fresh skb's with alloc_skb() and store skb pointer in rxdes3. Since
>>
>> rxdes3 does not store virtual address of an skb.
>> It stores the address of the buffer allocated while open() and freed
>> only when stop().
>> The data in that buffer will be memcpy()ed to an skb allocated in
>> ftmac100_rx_packet().
>> No double free happens.
>
> Ah, I blindly assumed that you're just appending the buffers to the
> skb (using skb_fill_page_desc() and friends). Since you have to mark
> descriptors for the device anyway, it might be faster to allocate new
> skbs and map those as rx buffers (changing the descriptor's buffer
> address after every RX) instead of keeping static buffer and copying
> every time. (For small packets it wastes lot of memory, though - so
> the right choice depends on the expected workload.)

The reason I chose to use memcpy rx buffer to skb is that I didn't know
how to deal with multi-segment packets if I preallocated skb for each
rx descriptor. This function seems to be what I need.
Let me rework this. Thanks.

best regards,
Po-Yu Chuang
