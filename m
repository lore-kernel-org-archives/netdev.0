From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Cannot set IPv6 address
Date: Thu, 17 Nov 2016 12:01:02 +0200
Message-ID: <CALzJLG9keRdRJua+S+wRvgz4Gud+n0z14LDs6CdHLmv2KQUf6A@mail.gmail.com>
References: <CALzJLG9B52CbMEiWgroaihq4Ar2Jc9H3BZdA_xjF37CZESbZ8Q@mail.gmail.com>
 <582C7C92.2000306@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Doron Tsur <doront@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37207 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936256AbcKQKBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:01:24 -0500
Received: by mail-wm0-f44.google.com with SMTP id t79so133795751wmt.0
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 02:01:24 -0800 (PST)
In-Reply-To: <582C7C92.2000306@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 5:34 PM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> On 11/16/2016 04:22 PM, Saeed Mahameed wrote:
>> Hi David,
>>
>> The following commit introduced a new issue when setting IPv6 address
>> via the following command:
>>
>> /sbin/ip -6 addr add 2001:0db8:0:f112::1/64 dev enp2s2
>> RTNETLINK answers: Operation not supported
>>
>> Offending commit:
>>
>> commit 6c8702c60b88651072460f3f4026c7dfe2521d12
>
> Saeed,
>
> Do you have LWTUNNEL enabled ? This commit introduced a bug causing IPv6

Disabled.

> initialization to fail if LWTUNNEL is disabled. The patch has been
> submitted to the list and is pending approval from DaveM.
>
> If you see something like
>
> NET: Registered protocol family 10
> IPv6: Attempt to unregister permanent protocol 6
> IPv6: Attempt to unregister permanent protocol 136
> IPv6: Attempt to unregister permanent protocol 17
> NET: Unregistered protocol family 10
>
> in you dmesg logs then it would confirm my theory.
>
> Short fix: enable CONFIG_LWTUNNEL or apply patch in attachment
>
> David

Looks like the fix was applied [1],
Thanks for the quick response.

[1] https://patchwork.ozlabs.org/patch/695060/.
