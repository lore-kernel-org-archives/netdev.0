From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Tue, 20 Jan 2015 15:06:26 -0800
Message-ID: <CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:52886 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbbATXG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 18:06:27 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so17349732igb.5
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 15:06:26 -0800 (PST)
In-Reply-To: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 12:25 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch series adds support for Stateless Transport
> Tunneling protocol.
> STT uses TCP segmentation offload available in most of NIC. On
> packet xmit STT driver appends STT header along with TCP header
> to the packet. For GSO packet GSO parameters are set according
> to tunnel configuration and packet is handed over to networking
> stack. This allows use of segmentation offload available in NICs
>
> Netperf unidirectional test gives ~9.4 Gbits/s performance on 10Gbit
> NIC with 1500 byte MTU with two TCP streams.
>
Having packets marked TCP which really aren't TCP is a rather scary
prospect to deploy in a real data center (TCP is kind of an important
protocol ;-) ). Can you give some more motivation on this, more data
that shows what the benefits are and how this compares to equivalent
encapsulation protocols that implement GRO and GSO.

Thanks,
Tom

> The protocol is documented at
> http://www.ietf.org/archive/id/draft-davie-stt-06.txt
>
> I will send out OVS userspace patch on ovs-dev mailing list.
>
> Pravin B Shelar (3):
>   skbuff: Add skb_list_linearize()
>   net: Add STT tunneling protocol.
>   openvswitch: Add support for STT tunneling.
>
>  include/linux/skbuff.h           |    2 +
>  include/net/stt.h                |   55 ++
>  include/uapi/linux/openvswitch.h |    1 +
>  net/core/skbuff.c                |   35 +
>  net/ipv4/Kconfig                 |   11 +
>  net/ipv4/Makefile                |    1 +
>  net/ipv4/stt.c                   | 1386 ++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/Kconfig          |   10 +
>  net/openvswitch/Makefile         |    1 +
>  net/openvswitch/vport-stt.c      |  214 ++++++
>  10 files changed, 1716 insertions(+)
>  create mode 100644 include/net/stt.h
>  create mode 100644 net/ipv4/stt.c
>  create mode 100644 net/openvswitch/vport-stt.c
>
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
