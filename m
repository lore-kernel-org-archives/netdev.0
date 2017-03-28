From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next 0/8] Add support for pipeline debug (dpipe)
Date: Tue, 28 Mar 2017 09:58:57 +0200
Message-ID: <49d3604b-1bf9-c43f-cf25-626fe082fafb@redhat.com>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
 <20170327.154834.1733255928137862540.davem@davemloft.net>
 <20170328065111.GA1873@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com, andrew@lunn.ch,
        simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754508AbdC1H7c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 03:59:32 -0400
In-Reply-To: <20170328065111.GA1873@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 28.3.2017 v 08:51 Jiri Pirko napsal(a):
> Tue, Mar 28, 2017 at 12:48:34AM CEST, davem@davemloft.net wrote:
>>
>> Please fix up these warnings and resubmit:
>>
>> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c: In function ‘mlxsw_sp_rif_counter_free’:
>> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:208:2: warning: ‘p_counter_index’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>  mlxsw_sp_rif_counter_edit(mlxsw_sp, rif->rif_index,
>>  ^
>> drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c: In function ‘mlxsw_sp_table_erif_entries_dump’:
>> drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:220:9: warning: missing braces around initializer [-Wmissing-braces]
>>  struct devlink_dpipe_value match_value = {0}, action_value = {0};
>
> I know about this warning. I believe that it is a gcc bug. It happens
> for gcc 4, but gcc 6 is silent, therefore I choose to ignore this. Do
> you still want me to fix it?
>
Yes, this is gcc bug (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53119). The 
problem is the first member of struct is union so older gcc assumes initializer 
like '{ { 0 } }' instead of '{ 0 }'.

IMHO it should be better to workaround this bug for older gccs as gcc6 is not 
only supported compiler.

Ivan
