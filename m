From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add igmpv3 and mldv2 query support
Date: Fri, 18 Nov 2016 11:31:00 +0100
Message-ID: <a5fe27de-e747-c1c6-7108-83124d1c000f@cumulusnetworks.com>
References: <1479454321-31304-1-git-send-email-liuhangbin@gmail.com>
 <9c1e16c2-b716-21e0-fa2c-3e3126607953@cumulusnetworks.com>
 <c1c35821-cdba-4a5e-0e53-694d10fb5918@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linus.luessing@c0d3.blue, roopa <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36926 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751905AbcKRKik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 05:38:40 -0500
Received: by mail-wm0-f50.google.com with SMTP id t79so28668263wmt.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 02:38:39 -0800 (PST)
In-Reply-To: <c1c35821-cdba-4a5e-0e53-694d10fb5918@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/11/16 11:09, Nikolay Aleksandrov wrote:
> On 18/11/16 11:04, Nikolay Aleksandrov wrote:
>> (+CC Roopa)
>> Hi Hangbin,
>> This patch is not correct, you should not use the net device IGMP config in the bridge.
> * bridge net device, sorry not port
>
>> These packets may never make it to the host and they may not be reflected, even more the
>> host may have very different igmp config for the port net device than the bridge does.
> * again bridge net device, not port
>
>> Also your current implementation switches to V3 only if it is globally set, and that should
>> be controlled on a per-bridge basis, even per-vlan later.
> * it is per-bridge, you use the global net device IGMP config, but it should be in the bridge
> mcast control options, so we can do it per-vlan later and also be able to do the compat parts
> of the RFC and in general, the bridge is configured via its own options not the host net device
> because as I said these packets may never be received locally

Having the host netdev options affect the bridge-specific config is really undesirable and confusing.

>
>> One more thing, if someone does a V2 leave for a group, you can end up sending them V3
>> group-specific query.
>>
>> I have been working on an implementation for IGMPv3/MLDv2 querier for the bridge device, it re-uses
>> most of the current code and allows you to configure it per-bridge (and later per-vlan). The only
>> reason I've not yet sent it to upstream is that we (at Cumulus) are working out the compatibility
>> parts (e.g. RFC3376 sec 7, sec 8) of the RFC since it has some unclear cases.

Err, RFC3376 sec 7.3.1, 7.3.2, and RFC3810 sec 8.3.1, 8.3.2

I really should get coffee.. sorry for the multiple emails :-)

>> But I can rip the compatibility out and send it early for review if you'd like, we can add the
>> compat code later.
>>
>> Cheers,
>>  Nik
>>
