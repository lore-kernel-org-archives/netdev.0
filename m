From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Fri, 25 Mar 2016 15:16:55 -0700
Message-ID: <CAM_iQpUgCf86eZ1+-3peJ4ij39QCQeQwGRAaoDeiL3HxCCMRKQ@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com>
	<CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
	<56F4810A.9060904@candelatech.com>
	<56F49036.8050902@candelatech.com>
	<56F490B2.3090603@candelatech.com>
	<CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
	<56F4BFF1.8010806@candelatech.com>
	<CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
	<56F4C8FD.7030907@candelatech.com>
	<CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
	<56F5A618.9070206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33222 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbcCYWQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:16:56 -0400
Received: by mail-qk0-f174.google.com with SMTP id s5so42389029qkd.0
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 15:16:55 -0700 (PDT)
In-Reply-To: <56F5A618.9070206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 1:56 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 03/24/2016 10:33 PM, Cong Wang wrote:
>
>> Here we go:
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 1ecfa71..ab66080 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1925,6 +1925,7 @@ static int packet_sendmsg_spkt(struct socket
>> *sock, struct msghdr *msg,
>>                  goto out_unlock;
>>          }
>>
>> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>>          skb->protocol = proto;
>>          skb->dev = dev;
>>          skb->priority = sk->sk_priority;
>> @@ -2496,6 +2497,7 @@ static int tpacket_fill_skb(struct packet_sock
>> *po, struct sk_buff *skb,
>>
>>          ph.raw = frame;
>>
>> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>>          skb->protocol = proto;
>>          skb->dev = dev;
>>          skb->priority = po->sk.sk_priority;
>> @@ -2805,6 +2807,7 @@ static struct sk_buff *packet_alloc_skb(struct
>> sock *sk, size_t prepad,
>>          skb_put(skb, linear);
>>          skb->data_len = len - linear;
>>          skb->len += len - linear;
>> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>>
>>          return skb;
>>   }
>
>
> I have tested UDP, TCP, TCPv6 and custom Ethernet frames across a veth pair.
>
> And, UDP, TCP, and pktgen across a pair of veth pairs
> bridged by my user-space packet filter.
>
> All of these tests work fine with your patch as far as I can tell.
>
> So, you can add:
>
> Tested-by: Ben Greear <greearb@candelatech.com>

Thanks for testing! I will send it out formally after I audit more drivers,
also let's give Tom some time to response.

>
> That said, it could easily break some drivers and/or other scenarios that I
> have not tested, so at the least it should cook a while upstream before
> going into the
> stable tree....

Yeah.

Thanks.
