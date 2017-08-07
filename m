From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 00/13] Update DSA's FDB API and perform
 switchdev cleanup
Date: Mon, 7 Aug 2017 11:48:57 -0700
Message-ID: <661b19a4-5c49-6ab1-41fe-fab83aa64572@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <87bmnrifte.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32832 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdHGStD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:49:03 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so904145wrd.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:49:02 -0700 (PDT)
In-Reply-To: <87bmnrifte.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 07:59 AM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
> 
>> The patchset adds support for configuring static FDB entries via the
>> switchdev notification chain. The current method for FDB configuration
>> uses the switchdev's bridge bypass implementation. In order to support 
>> this legacy way and to perform the switchdev cleanup, the implementation
>> is moved inside DSA.
>>
>> The DSA drivers cannot sync the software bridge with hardware learned
>> entries and use the switchdev's implementation of bypass FDB dumping.
>> Because they are the only ones using this functionality, the fdb_dump
>> implementation is moved from switchdev code into DSA.
>>
>> Finally after this changes a major cleanup in switchdev can be done.
>> ---
>> Please see individual patches for patch specific change logs.
>> v1->v2
>> - Split MDB/vlan dump removal into core/driver removal.
>>
>> v2->v3
>> - The self implementation for FDB add/del is moved inside DSA.
> 
> v3 behaves correctly:
> 
>     # bridge fdb add e4:1d:2d:a5:f0:2a dev lan3
>     # bridge fdb add e4:1d:2d:a5:f0:4a dev lan4 master
>     # bridge fdb show
>     01:00:5e:00:00:01 dev eth0 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     b6:f2:c8:3a:1c:71 dev lan0 master br0 permanent
>     e4:1d:2d:a5:f0:2a dev lan3 self static
>     e4:1d:2d:a5:f0:4a dev lan4 offload master br0 permanent
>     e4:1d:2d:a5:f0:4a dev lan4 self static
>     01:00:5e:00:00:01 dev br0 self permanent
>     # bridge fdb del e4:1d:2d:a5:f0:2a dev lan3
>     # bridge fdb del e4:1d:2d:a5:f0:4a dev lan4 master
>     # bridge fdb show
>     01:00:5e:00:00:01 dev eth0 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     b6:f2:c8:3a:1c:71 dev lan0 master br0 permanent
>     01:00:5e:00:00:01 dev br0 self permanent
> 
> Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Same here:

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

thanks!
-- 
Florian
