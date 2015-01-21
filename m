From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: Do not require sock in udp_tunnel_xmit_skb
Date: Thu, 22 Jan 2015 00:37:59 +0200
Message-ID: <CAJ3xEMhMgXLAv5qPXgUTdiTBuBuYO-DPczSvXOjKHfD0WsAn-g@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
	<1421518700-22460-2-git-send-email-therbert@google.com>
	<CAJ3xEMg0xJU4JShBLzs4g+zZVzH+uo79=aQGx4NwoQOv1h13Kw@mail.gmail.com>
	<CA+mtBx8dihFYb1v_WeyukfV5hk==2=3_b_GNUJoxCuL8_GUf6A@mail.gmail.com>
	<CAJ3xEMit2By8S=SwRGJKcwii9J3LKj29sX=tAbCC3bcAMDkr5Q@mail.gmail.com>
	<CA+mtBx80QDU4FJfzh0WATTuaDGS4vaBv0H0r8AfmKjw0rk1f3A@mail.gmail.com>
	<CAJ3xEMhX+2J5hRuxF9_694sqxsMwi0LuwiEAK1G2-ZBaOPgBTQ@mail.gmail.com>
	<CA+mtBx_uwwDV+ogt6BeYH36qLztJLt75H9Z_r0BY5FjkixdBCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:60573 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbAUWh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 17:37:59 -0500
Received: by mail-oi0-f48.google.com with SMTP id v63so3832403oia.7
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 14:37:59 -0800 (PST)
In-Reply-To: <CA+mtBx_uwwDV+ogt6BeYH36qLztJLt75H9Z_r0BY5FjkixdBCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 12:24 AM, Tom Herbert <therbert@google.com> wrote:
> On Wed, Jan 21, 2015 at 12:57 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Wed, Jan 21, 2015 at 12:24 AM, Tom Herbert <therbert@google.com> wrote:
>>> vxlan_xmit_one calls udp_flow_src_port to get a source port value
>>> based on the encapsulated flow.
>>
>> OK, got it -- does a by-product of invoking udp_flow_src_port on the
>> skb is having an hash mark on the skb which is based on the inner
>> packet and can (is?) used for TX queue selection over MQ devices?
>
> Yes, that should be fine. The hash can be used all the way up to TCP
> and save in the TCP socket as the rxhash for a connection. This was
> RFS, XPS, etc. will work for TCP over an encapsulation.


so.. can be used or is already used today? Also we're talking on the
TX path, so I wasn't sure to follow on your mentioning of RFS...
