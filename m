From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 7/9] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 19 Aug 2015 11:29:41 -0700
Message-ID: <CALnjE+ojRD_QKY3A9EomCg6yZ2BR+jiSFjndzN+U+8aBP2b7GQ@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-8-git-send-email-pshelar@nicira.com>
	<CAEP_g=_4FHejf_qfXbXzO3kyx1WJ2ssOY9OMF=vySFNu-CPOqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33064 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbbHSS3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:29:42 -0400
Received: by iods203 with SMTP id s203so19292739iod.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:29:42 -0700 (PDT)
In-Reply-To: <CAEP_g=_4FHejf_qfXbXzO3kyx1WJ2ssOY9OMF=vySFNu-CPOqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 11:18 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index e58468b..18ff83b 100644
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
> I think my comments on v1 one this patch were overlooked (about the
> UDP_TUNNEL dependency and the name).
>
right, I missed it.

>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index 5b43382..eb298ff 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> +static void geneve_build_header(struct genevehdr *geneveh,
>> +                               __be16 tun_flags, u8 vni[3],
>> +                               u8 options_len, u8 *options)
> [...]
>> +static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
>> +                           __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
>> +                           bool csum)
>
> It seems like we could just merge these functions. I'm not sure that
> the role is all that different.
>
ok.

> In geneve_build_skb(), the error labels are somewhat confusing (for
> example, free_rt doesn't free the rt). Also, is it right that we don't
> free the rt if udp_tunnel_handle_offloads() fails()? It might be
> cleaner if the caller retains ownership of rt.
>
ok.

> My guess is that if the issue from the earlier patch about overlapping
> collect_md tunnels is fixed then that might allow us to simplify
> things a little further, since for those tunnels we can assume there
> is a 1:1 mapping between collect_md tunnels and sockets.

I dont see how it would be different. Can you elaborate on this ?
