From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too long
Date: Wed, 20 Mar 2013 14:01:09 -0700
Message-ID: <CAE9FiQURBR=iTbksUzb_i23g6N56Acg2J8bab9zr1UcwT5tWzA@mail.gmail.com>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
	<1363693648-10015-2-git-send-email-yamato@redhat.com>
	<20130320.120705.58997943737455552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yamato@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Zhang Rui <rui.zhang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:61555 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab3CTVBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 17:01:09 -0400
Received: by mail-ie0-f172.google.com with SMTP id c10so2707258ieb.3
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 14:01:09 -0700 (PDT)
In-Reply-To: <20130320.120705.58997943737455552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 9:07 AM, David Miller <davem@davemloft.net> wrote:
> From: Masatake YAMATO <yamato@redhat.com>
> Date: Tue, 19 Mar 2013 20:47:27 +0900
>
>> Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
>>
>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>
> Applied, thanks.

catch one in

drivers/thermal/thermal_sys.c::genetlink_init

        result = genl_register_mc_group(&thermal_event_genl_family,
                                        &thermal_event_mcgrp);

and

static struct genl_multicast_group thermal_event_mcgrp = {
        .name = THERMAL_GENL_MCAST_GROUP_NAME,
};

#define THERMAL_GENL_MCAST_GROUP_NAME           "thermal_mc_group"

that string len 16.
