From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_veth_regression_with_=22don=e2=80=99t_modify_ip=5fsum?=
 =?UTF-8?Q?med;_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Fri, 25 Mar 2016 13:56:56 -0700
Message-ID: <56F5A618.9070206@candelatech.com>
References: <56F463D6.7080406@candelatech.com>
 <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
 <56F490B2.3090603@candelatech.com>
 <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
 <56F4BFF1.8010806@candelatech.com>
 <CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
 <56F4C8FD.7030907@candelatech.com>
 <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:42367 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbcCYU45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 16:56:57 -0400
In-Reply-To: <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2016 10:33 PM, Cong Wang wrote:

> Here we go:
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 1ecfa71..ab66080 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1925,6 +1925,7 @@ static int packet_sendmsg_spkt(struct socket
> *sock, struct msghdr *msg,
>                  goto out_unlock;
>          }
>
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>          skb->protocol = proto;
>          skb->dev = dev;
>          skb->priority = sk->sk_priority;
> @@ -2496,6 +2497,7 @@ static int tpacket_fill_skb(struct packet_sock
> *po, struct sk_buff *skb,
>
>          ph.raw = frame;
>
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>          skb->protocol = proto;
>          skb->dev = dev;
>          skb->priority = po->sk.sk_priority;
> @@ -2805,6 +2807,7 @@ static struct sk_buff *packet_alloc_skb(struct
> sock *sk, size_t prepad,
>          skb_put(skb, linear);
>          skb->data_len = len - linear;
>          skb->len += len - linear;
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>
>          return skb;
>   }

I have tested UDP, TCP, TCPv6 and custom Ethernet frames across a veth pair.

And, UDP, TCP, and pktgen across a pair of veth pairs
bridged by my user-space packet filter.

All of these tests work fine with your patch as far as I can tell.

So, you can add:

Tested-by: Ben Greear <greearb@candelatech.com>

That said, it could easily break some drivers and/or other scenarios that I
have not tested, so at the least it should cook a while upstream before going into the
stable tree....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
