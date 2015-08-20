From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 5/9] geneve: Add support to collect tunnel metadata.
Date: Thu, 20 Aug 2015 13:31:37 -0700
Message-ID: <CALnjE+pSK620seiO==uXt=gTdc_sf2PS+=5_WLXGR40-LoJkng@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-6-git-send-email-pshelar@nicira.com>
	<CAEP_g=-gJeMDi_agxOmuvhvLwKpQeQZAmy55MWenvr_1bwt2Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35222 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbbHTUbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:31:38 -0400
Received: by iodt126 with SMTP id t126so60066237iod.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 13:31:38 -0700 (PDT)
In-Reply-To: <CAEP_g=-gJeMDi_agxOmuvhvLwKpQeQZAmy55MWenvr_1bwt2Gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 6:07 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index 546494d..cb2d874 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> +static int geneve_configure(struct net *net, struct net_device *dev,
>> +                           __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
>> +                           __u16 dst_port, bool metadata)
> [...]
>> -       if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
>> -               return -EINVAL;
>> +       if (metadata && rtnl_dereference(gn->collect_md_tun))
>> +               return -EEXIST;
>
> This will allow you to configure a collect_md_tun devices and normal
> devices on top of each other, even though the latter will never get
> hit in that situation.

ok. I will make them mutually exclusive.
