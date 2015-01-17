From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] net: replace br_fdb_external_learn_* calls
 with switchdev notifier events
Date: Sat, 17 Jan 2015 09:31:12 +0100
Message-ID: <20150117083112.GB1891@nanopsycho.orion>
References: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
 <1421362177-10719-2-git-send-email-jiri@resnulli.us>
 <CAE4R7bAXvxFzuvuz5YPviTDsMLCYWnQxbkHkVJbjYq6+K574rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.co>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	linus.luessing@web.de, Thomas Graf <tgraf@suug.ch>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:55980 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbAQIbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 03:31:14 -0500
Received: by mail-we0-f178.google.com with SMTP id p10so23744413wes.9
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 00:31:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAXvxFzuvuz5YPviTDsMLCYWnQxbkHkVJbjYq6+K574rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 16, 2015 at 08:32:34PM CET, sfeldma@gmail.com wrote:
>On Thu, Jan 15, 2015 at 2:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This patch benefits from newly introduced switchdev notifier and uses it
>> to propagate fdb learn events from rocker driver to bridge. That avoids
>> direct function calls and possible use by other listeners (ovs).
>>
>> Suggested-by: Thomas Graf <tgraf@suug.ch>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
>>  drivers/net/ethernet/rocker/rocker.c | 10 +++++--
>>  include/linux/if_bridge.h            | 18 -------------
>>  include/net/switchdev.h              | 11 ++++++++
>>  net/bridge/br.c                      | 52 +++++++++++++++++++++++++++++++++++-
>>  net/bridge/br_fdb.c                  | 38 +++-----------------------
>>  net/bridge/br_private.h              |  4 +++
>>  6 files changed, 78 insertions(+), 55 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index cad8cf9..964d719 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3026,11 +3026,17 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
>>                 container_of(work, struct rocker_fdb_learn_work, work);
>>         bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
>>         bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
>> +       struct netdev_switch_notifier_fdb_info info;
>> +
>> +       info.addr = lw->addr;
>> +       info.vid = lw->vid;
>
>If you respin patch, use initializer to zero out other members, just
>to future proof it.

There are no other members :)
