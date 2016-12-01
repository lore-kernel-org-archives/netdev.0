From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable() for
 length check.
Date: Thu, 1 Dec 2016 11:50:00 -0800
Message-ID: <CAOrHB_BEQBbvDa2W0dJmmANsjZEiwx7GbTxo-7yirDB=5d9cqQ@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
 <1480462253-114713-2-git-send-email-jarno@ovn.org> <20161130145159.3cee7ba4@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:51268 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932933AbcLATuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:50:06 -0500
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id BBDDAC5A5D
        for <netdev@vger.kernel.org>; Thu,  1 Dec 2016 20:50:03 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 9KOJZIBQ9N1m for <netdev@vger.kernel.org>;
        Thu,  1 Dec 2016 20:50:01 +0100 (CET)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id ABEB1C5A6F
        for <netdev@vger.kernel.org>; Thu,  1 Dec 2016 20:50:01 +0100 (CET)
Received: by mail-io0-f172.google.com with SMTP id j65so443451345iof.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 11:50:01 -0800 (PST)
In-Reply-To: <20161130145159.3cee7ba4@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 5:51 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 29 Nov 2016 15:30:52 -0800, Jarno Rajahalme wrote:
>> @@ -504,11 +485,20 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
>>               goto drop;
>>       }
>>
>> -     if (unlikely(packet_length(skb, vport->dev) > mtu &&
>> -                  !skb_is_gso(skb))) {
>> -             net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
>> -                                  vport->dev->name,
>> -                                  packet_length(skb, vport->dev), mtu);
>> +     if (unlikely(!is_skb_forwardable(vport->dev, skb))) {
>
> How does this work when the vlan tag is accelerated? Then we can be
> over MTU, yet the check will pass.
>

This is not changing any behavior compared to current OVS vlan checks.
Single vlan header is not considered for MTU check.
