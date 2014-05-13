From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Mon, 12 May 2014 17:13:29 -0700
Message-ID: <CAEP_g=8L0hse+AezexT7NDgEs0A1sjP3NY9LC7C-5wDsf-OAEQ@mail.gmail.com>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
 <CAEP_g=9BTrUN48uV2teyufmG7QPZHmYsMrvWOBs9JhJam2oOVw@mail.gmail.com> <CA+mtBx-0GHNRZ+midMYa4SNv33jmF62Cgv2Y188JqPnx7NH5bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog022.obsmtp.com ([74.125.150.84]:45417 "HELO
	na6sys009bog022.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751923AbaEMANv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 20:13:51 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so8623134qgf.35
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 17:13:50 -0700 (PDT)
In-Reply-To: <CA+mtBx-0GHNRZ+midMYa4SNv33jmF62Cgv2Y188JqPnx7NH5bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 4:35 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, May 12, 2014 at 2:41 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Mon, May 12, 2014 at 9:59 AM, Tom Herbert <therbert@google.com> wrote:
>>> @@ -1756,7 +1754,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>>>         uh->source = src_port;
>>>
>>>         uh->len = htons(skb->len);
>>> -       uh->check = 0;
>>> +
>>> +       udp_set_csum(vs->sock->sk, skb, src, dst, skb->len);
>>
>> How does this interact with inner checksum offloading? I don't think
>> that we have any infrastructure to support computing two checksums on
>> a packet yet.
>
> Right, as it stands now we could overwrite the csum offload parameters
> for the inner header which would be a problem. I will fix that.
>
> The ability to offload two csums in TX could be quite useful for
> encapsulations like vxlan. I don't know if any HW is planning to
> support that...

I think it would be good to assume that we might want to do that as
something might appear in the not too distant future...
