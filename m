From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Mon, 12 May 2014 16:35:21 -0700
Message-ID: <CA+mtBx-0GHNRZ+midMYa4SNv33jmF62Cgv2Y188JqPnx7NH5bg@mail.gmail.com>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
	<CAEP_g=9BTrUN48uV2teyufmG7QPZHmYsMrvWOBs9JhJam2oOVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:59116 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbaELXfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 19:35:21 -0400
Received: by mail-ig0-f179.google.com with SMTP id hn18so4527501igb.0
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 16:35:21 -0700 (PDT)
In-Reply-To: <CAEP_g=9BTrUN48uV2teyufmG7QPZHmYsMrvWOBs9JhJam2oOVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 2:41 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, May 12, 2014 at 9:59 AM, Tom Herbert <therbert@google.com> wrote:
>> @@ -1756,7 +1754,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>>         uh->source = src_port;
>>
>>         uh->len = htons(skb->len);
>> -       uh->check = 0;
>> +
>> +       udp_set_csum(vs->sock->sk, skb, src, dst, skb->len);
>
> How does this interact with inner checksum offloading? I don't think
> that we have any infrastructure to support computing two checksums on
> a packet yet.

Right, as it stands now we could overwrite the csum offload parameters
for the inner header which would be a problem. I will fix that.

The ability to offload two csums in TX could be quite useful for
encapsulations like vxlan. I don't know if any HW is planning to
support that...
