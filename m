From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 1/2] udp: Do not require sock in udp_tunnel_xmit_skb
Date: Wed, 21 Jan 2015 14:55:35 -0800
Message-ID: <CA+mtBx8ON8+UtsGPtiDnqzKq8BH10-8_zU2_=CjiDnkqZo0okw@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
	<1421518700-22460-2-git-send-email-therbert@google.com>
	<CAJ3xEMg0xJU4JShBLzs4g+zZVzH+uo79=aQGx4NwoQOv1h13Kw@mail.gmail.com>
	<CA+mtBx8dihFYb1v_WeyukfV5hk==2=3_b_GNUJoxCuL8_GUf6A@mail.gmail.com>
	<CAJ3xEMit2By8S=SwRGJKcwii9J3LKj29sX=tAbCC3bcAMDkr5Q@mail.gmail.com>
	<CA+mtBx80QDU4FJfzh0WATTuaDGS4vaBv0H0r8AfmKjw0rk1f3A@mail.gmail.com>
	<CAJ3xEMhX+2J5hRuxF9_694sqxsMwi0LuwiEAK1G2-ZBaOPgBTQ@mail.gmail.com>
	<CA+mtBx_uwwDV+ogt6BeYH36qLztJLt75H9Z_r0BY5FjkixdBCw@mail.gmail.com>
	<CAJ3xEMhMgXLAv5qPXgUTdiTBuBuYO-DPczSvXOjKHfD0WsAn-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:46829 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbAUWzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 17:55:36 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so10806174ier.10
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 14:55:35 -0800 (PST)
In-Reply-To: <CAJ3xEMhMgXLAv5qPXgUTdiTBuBuYO-DPczSvXOjKHfD0WsAn-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 2:37 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Thu, Jan 22, 2015 at 12:24 AM, Tom Herbert <therbert@google.com> wrote:
>> On Wed, Jan 21, 2015 at 12:57 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Wed, Jan 21, 2015 at 12:24 AM, Tom Herbert <therbert@google.com> wrote:
>>>> vxlan_xmit_one calls udp_flow_src_port to get a source port value
>>>> based on the encapsulated flow.
>>>
>>> OK, got it -- does a by-product of invoking udp_flow_src_port on the
>>> skb is having an hash mark on the skb which is based on the inner
>>> packet and can (is?) used for TX queue selection over MQ devices?
>>
>> Yes, that should be fine. The hash can be used all the way up to TCP
>> and save in the TCP socket as the rxhash for a connection. This was
>> RFS, XPS, etc. will work for TCP over an encapsulation.
>
>
> so.. can be used or is already used today? Also we're talking on the
> TX path, so I wasn't sure to follow on your mentioning of RFS...

Yes. AFAIK all encapsulation implementations are single queue and
otherwise transparent to the application layer for the hash and queue
selection.

Is there a particular feature you're having trouble with?

Thanks,
Tom
