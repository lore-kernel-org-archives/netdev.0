From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next 0/8] Add support for pipeline debug (dpipe)
Date: Tue, 28 Mar 2017 10:10:23 +0200
Message-ID: <96ad92ca-c3ad-8e31-9802-46f298bbc9fa@redhat.com>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
 <20170327.154834.1733255928137862540.davem@davemloft.net>
 <20170328071051.GB1873@nanopsycho.orion>
 <251a02fa-4c4a-bd69-1411-74a0c79726a2@redhat.com>
 <20170328075722.GC1873@nanopsycho.orion>
 <20170328075909.GD1873@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        arkadis@mellanox.com, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754612AbdC1IKj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 04:10:39 -0400
In-Reply-To: <20170328075909.GD1873@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 28.3.2017 v 09:59 Jiri Pirko napsal(a):
> Tue, Mar 28, 2017 at 09:57:22AM CEST, jiri@resnulli.us wrote:
>> Tue, Mar 28, 2017 at 09:42:58AM CEST, ivecera@redhat.com wrote:
>>> Dne 28.3.2017 v 09:10 Jiri Pirko napsal(a):
>>>> Tue, Mar 28, 2017 at 12:48:34AM CEST, davem@davemloft.net wrote:
>>>>>
>>>>> Please fix up these warnings and resubmit:
>>>>>
>>>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c: In function ‘mlxsw_sp_rif_counter_free’:
>>>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:208:2: warning: ‘p_counter_index’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>>>>  mlxsw_sp_rif_counter_edit(mlxsw_sp, rif->rif_index,
>>>>>  ^
>>>>
>>>> This is I believe also gcc bug. Code looks fine. I'm not getting the warning
>>>> with gcc 6
>>>>
>>> No it is not a gcc bug. The function mlxsw_sp_rif_counter_free() is not
>>> static so the compiler cannot know all its callers and so 'dir' parameter can
>>> be theoretically anything.
>>> You call mlxsw_sp_rif_p_counter_get() there it assumes dir can be only
>>> MLXSW_SP_RIF_COUNTER_EGRESS or MLXSW_SP_RIF_COUNTER_INGRESS so initializes
>>> *pp_counter_index only for them. For any other value the value is
>>> uninitialized.
>>
>> Interesting, why gcc 6.2.1 is silent then?
>
> Oh, I see that it is not :) My bad, will fix, thanks!
>
Probably because 'dir' is enumeration and this gcc assumes that any caller uses 
only defined enum values.

Ivan
