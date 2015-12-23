From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] ip_tunnel: Move stats update to iptunnel_xmit()
Date: Wed, 23 Dec 2015 14:35:29 -0800
Message-ID: <CALnjE+qnj4mZrOiCN1TpaKdxhVrJLq7Z25sDcMFqYWVa2od0pg@mail.gmail.com>
References: <1450744476-23539-1-git-send-email-pshelar@nicira.com>
	<567A6E13.3080909@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36429 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbbLWWfa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 17:35:30 -0500
Received: by mail-io0-f172.google.com with SMTP id o67so228135985iof.3
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 14:35:30 -0800 (PST)
In-Reply-To: <567A6E13.3080909@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 1:49 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 22/12/2015 01:34, Pravin B Shelar a =C3=A9crit :
>>
>> By moving stats update into iptunnel_xmit(), we can simplify
>> iptunnel_xmit() usage. With this change there is no need to
>> call another function (iptunnel_xmit_stats()) to update stats
>> in tunnel xmit code path.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>
> [snip]
>>
>> +static inline void iptunnel_xmit_stats(struct net_device *dev, int =
err)
>>   {
>>         if (err > 0) {
>> -               struct pcpu_sw_netstats *tstats =3D get_cpu_ptr(stat=
s);
>> +               struct pcpu_sw_netstats *tstats =3D
>> get_cpu_ptr(dev->tstats);
>>
>>                 u64_stats_update_begin(&tstats->syncp);
>>                 tstats->tx_bytes +=3D err;
>>                 tstats->tx_packets++;
>>                 u64_stats_update_end(&tstats->syncp);
>>                 put_cpu_ptr(tstats);
>> -       } else if (err < 0) {
>> +       } else {
>> +               struct net_device_stats *err_stats =3D &dev->stats;
>> +
>>                 err_stats->tx_errors++;
>>                 err_stats->tx_aborted_errors++;
>> -       } else {
>> -               err_stats->tx_dropped++;
>>         }
>>   }
>
> Why do you remove the case 'err =3D=3D 0'?
> At least, it needs an explanation in the commit log.

I wanted to unify all ip_out() error stats under single count, But now
I think it is better to separate that change into another patch. I
will send updated patch without this change.
