From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/13] Change DSA's FDB API and perform
 switchdev cleanup
Date: Fri, 4 Aug 2017 07:23:01 +0200
Message-ID: <20170804052301.GA1906@nanopsycho.orion>
References: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
 <87mv80ji63.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <099a0552-0139-20d4-2529-c1202303d772@mellanox.com>
 <87pocvnkfw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <ede22100-3a66-f54d-a618-a3b840a2664c@mellanox.com>
 <aa4f3dc5-6693-4de8-5191-f0a939ff8168@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, davem@davemloft.net, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32768 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751259AbdHDFXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 01:23:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so4463480wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 22:23:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <aa4f3dc5-6693-4de8-5191-f0a939ff8168@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 04, 2017 at 12:39:02AM CEST, arkadis@mellanox.com wrote:
>
>[...]
>
>>> Now we have the "offload" read only flag, which is good to inform about
>>> a successfully programmed hardware, but adds another level of complexity
>>> to understand the interaction with the hardware.
>>>
>>> I think iproute2 is getting more and more confusing. From what I
>>> understood, respecting the "self" flag as described is not possible
>>> anymore due to some retro-compatibility reasons.
>>>
>>> Also Linux must use the hardware as an accelerator (so "self" or
>>> "offload" must be the default), and always fall back to software
>>> otherwise, hence "master" do not make sense here.
>>>
>>> What do you think about this synopsis for bridge fdb add?
>>>
>>>     # bridge fdb add LLADDR dev DEV [ offload { on | off } ]
>>>
>>> Where offload defaults to "on". This option should also be ported to
>>> other offloaded features like MDB and VLAN. Even though this is a bit
>>> out of scope of this patchset, do you think this is feasible?
>>>
>> 
>> I agree completely that currently its confusing. The documentation
>> should be updated for sure. I think that 'self' was primarily introduced
>> (Commit 77162022a) for NIC embedded switches which are used for sriov, in
>> that case the self is related to the internal eswitch, which completely
>> diverge from the software one (clearly not swithcdev).
>> 
>> IMHO For switchdev devices 'self' should not be an option at all, or any
>> other arg regarding hardware. Furthermore, the 'offload' flag should be
>> only relevant during the dump as an indication to the user.
>> 
>> Unfortunately, the  lack of ability of syncing the sw with hw in DSA's
>> case introduces a problem for indicating that the entries are only
>> in hw, I mean marking it only as offloaded is not enough.
>
>Hi,
>
>It seems impossible currently to move the self to be the default, and
>this introduces regression which you don't approve, so it seems few
>options left:
>
>a) Leave two ways to add fdb, through the bridge (by using the master
>   flag) which is introduced in this patchset, and by using the self
>   which is the legacy way. In this way no regression will be introduced,
>   yet, it feels confusing a bit. The benefit is that we (DSA/mlxsw)
>   will be synced.
>b) Leave only the self (which means removing patch no 4,5).

I belive that option a) is the correct way to go. Introduction of self
inclusion was a mistake from the very beginning. I think that we should
just move one and correct this mistake.

Vivien, any arguments against a)?

Thanks!


>
>In both cases the switchdev implementation of .ndo_fdb_add() will be
>moved inside DSA in a similar way to the dump because its only used by
>you.
>
>Option b) actually turns this patchset into cosmetic one which does
>only cleanup.
>
>Thanks,
>Arkadi
>
>
>
>
