From: Joe Stringer <joe@ovn.org>
Subject: Re: Maximum MPLS labels on Linux network stack
Date: Wed, 3 May 2017 13:21:16 -0700
Message-ID: <CAPWQB7FFwBFL9h7JoJMF4FuK7JXLrHfo5yg4aHJ4iczSdNU_bg@mail.gmail.com>
References: <149211493832787@web33j.yandex.ru> <5a408c23-d3e2-aa3e-4574-82521b2255b0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>, netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:60376 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754355AbdECUVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 16:21:41 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id BFE211720C8
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 22:21:39 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 0z-CH7A0b0lD for <netdev@vger.kernel.org>;
        Wed,  3 May 2017 22:21:38 +0200 (CEST)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 50BCF1720A9
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 22:21:38 +0200 (CEST)
Received: by mail-qk0-f177.google.com with SMTP id q1so613299qkd.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 13:21:38 -0700 (PDT)
In-Reply-To: <5a408c23-d3e2-aa3e-4574-82521b2255b0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 May 2017 at 11:14, David Ahern <dsahern@gmail.com> wrote:
> On 5/3/17 11:33 AM, Алексей Болдырев wrote:
>> I watched one forum, there is listed in the properties of one license for Cisco, it says:
>>
>> Layer 3 VPN • Multi-VRF CE (VRF-lite); requires IP Services Feature license
>> • MPLS VPN; requires Advanced IP Feature license
>> • 26 VRFs
>
> There is no direct limit on the number of VRFs the kernel allows you to
> create. There are indirect ones -- total memory in the system and limits
> such as /proc/sys/net/ipv6/route/max_size. By increasing the latter I
> have created 4k VRFs in a system.
>
>
>> • 8192 MPLS labels
>>
>> Especially interested in the figure 8192 MPLS Labels.
>
> 8192 labels added in one pass is absurd. There is no reason to support
> such a number. With the latest version of the MPLS stack in the kernel
> you can add up to 30 labels in a single route. If you want more you have
> to either recirculate the packet using routes or recompile the kernel
> and increase the memory limit and the number of labels limit.
>
>>
>> As I understand it, is it either a limit on the number of labels on the stack or the total number of labels?
>>
>> In Linux, for example, you can specify a common col- lection of labels through /proc/sys/net/mpls/platforms_labels
>
> that just allocates the size of an array which dictates the max label
> number for that namespace. The array needs to be converted to a hash
> table at some point.
>
>>
>> Also I would like to know if the openvswitch has a limit of 3 tags in the stack or the total number of MPLS labels that can send?
>>
>
> someone familiar with OVS needs to answer that.

That would be 3 tags in a stack. When we spoke to people involved in
the design and usage of MPLS in practice, we got the impression that
it's very rare for anyone to configure a setup where more than that is
used concurrently on a packet. If you believe the contrary, then I
imagine it's not hard to bump that limit.

There is no limit on which labels can be used from OVS, it's just a
number in an action attached to a flow.
