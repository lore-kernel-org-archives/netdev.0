From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/2] drivers: add vpls support
Date: Sat, 12 Aug 2017 19:46:28 -0700
Message-ID: <CAJieiUhz2dAdGkdQPPfoqzfq3Kg_DzHkWL1+PZbqxhu3KFDeRg@mail.gmail.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-3-git-send-email-amine.kherbouche@6wind.com>
 <20170811125547.GZ773745@eidolon> <CAJieiUjiDuhOeGZH9hMf4zTSKfkQ9bhzb9_XE9+5V1ZaDa_f2A@mail.gmail.com>
 <0c3d6029-faa6-aa40-7db5-0970734868b8@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Lamparter <equinox@diac24.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:32889 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdHMCqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 22:46:30 -0400
Received: by mail-vk0-f42.google.com with SMTP id j189so23541920vka.0
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 19:46:29 -0700 (PDT)
In-Reply-To: <0c3d6029-faa6-aa40-7db5-0970734868b8@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 12, 2017 at 6:40 AM, Amine Kherbouche
<amine.kherbouche@6wind.com> wrote:
>
>
> On 11/08/2017 17:14, Roopa Prabhu wrote:
>>
>> On Fri, Aug 11, 2017 at 5:55 AM, David Lamparter <equinox@diac24.net>
>> wrote:
>>>
>>> On Thu, Aug 10, 2017 at 10:28:37PM +0200, Amine Kherbouche wrote:
>>>>
>>>> This commit introduces the support of VPLS virtual device, that allows
>>>> performing  L2VPN multipoint to multipoint communication over MPLS PSN.
>>>>
>>>> VPLS device encap received ethernet frame over mpls packet and send it
>>>> the
>>>> output device, in the other direction, when receiving the right
>>>> configured
>>>> mpls packet, the matched mpls route calls the handler vpls function,
>>>> then pulls out the mpls header and send it back the entry point via
>>>> netif_rx().
>>>>
>>>> Two functions, mpls_entry_encode() and mpls_output_possible() are
>>>> exported from mpls/internal.h to be able to use them inside vpls driver.
>>>>
>>>> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
>>
>> [snip]
>>
>>> [...]
>>>>
>>>> +union vpls_nh {
>>>> +     struct in6_addr         addr6;
>>>> +     struct in_addr          addr;
>>>> +};
>>>> +
>>>> +struct vpls_dst {
>>>> +     struct net_device       *dev;
>>>> +     union vpls_nh           addr;
>>>> +     u32                     label_in, label_out;
>>>> +     u32                     id;
>>>> +     u16                     vlan_id;
>>>
>>> I looked at VLAN support and decided against it because the bridge layer
>>> can handle this perfectly fine by using the bridge's vlan support to tag
>>> a port's pvid.
>>
>> yes, agreed. there is no need for vlan here. The bridge can be
>> configured with the required vlan
>> mapping on the vpls port.
>
> what if the output device cannot handle vlan encapsulation? because on my
> example of configuration in the cover letter, I sent the vpls packets over
> a simple physical net device (not a bridge nor a vlan port).

There are already multiple ways vlan encap is added today, eg vlan
device, under a bridge, using tc etc. I don't think every driver
should carry vlan encap info. see vxlan as an example, it does
not....you can use a bridge or tc etc for the vlan to vni map. You
will need a bridge anyways for fwding db, stp etc in such deployments.

We can add vlan in the future if it becomes necessary. I don't see a need today.
