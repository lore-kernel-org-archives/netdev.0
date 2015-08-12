From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 5/6] geneve: Consolidate Geneve functionality in
 single module.
Date: Wed, 12 Aug 2015 16:33:45 -0700
Message-ID: <CALnjE+pzgLwWgqYjE2wwyvbLUQ9fkX+4VJo_Ow44pHV0hhRbGg@mail.gmail.com>
References: <1439356673-21844-1-git-send-email-pshelar@nicira.com>
	<CAEP_g=8zvvosyueA-gudpYq1pCi4dCusW33wcCscpga8JLWz-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35826 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbbHLXdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:33:46 -0400
Received: by iodt126 with SMTP id t126so36331215iod.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 16:33:45 -0700 (PDT)
In-Reply-To: <CAEP_g=8zvvosyueA-gudpYq1pCi4dCusW33wcCscpga8JLWz-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 2:55 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index c18f9e6..0002ab7 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -181,7 +181,7 @@ config VXLAN
>>
>>  config GENEVE
>>         tristate "Generic Network Virtualization Encapsulation netdev"
>> -       depends on INET && GENEVE_CORE
>> +       depends on INET
>>         select NET_IP_TUNNEL
>
> I think this now needs to select NET_UDP_TUNNEL instead of NET_IP_TUNNEL.
>
ok.

> I would also drop "netdev" from the end of the title since there is no
> longer a split between the netdev and library.
>
ok.

> The farther I go in the series, the more that I hope that we can avoid
> the use of collect_md_tun. It really seems to add a lot of special
> cases.

Use of collect_md_tun allows us to avoid hash table lookup. thats why
I did it. Anyways we need a flag or pointer in geneve-sock structure
to locate tunnel metadata. I dont see how is it simple if
collect_md_tun is replaced with a flag.
