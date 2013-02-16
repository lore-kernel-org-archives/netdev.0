From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 3/4] tunneling: Add generic UDP-Tunnel TSO.
Date: Fri, 15 Feb 2013 17:39:50 -0800
Message-ID: <CALnjE+oUTOCM=gMTVKRkx40z_dFvG6_t+rzf26WgFa8F+fOsUw@mail.gmail.com>
References: <1360976774-1891-1-git-send-email-pshelar@nicira.com>
	<1360978480.19353.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:41336 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750858Ab3BPBjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:39:51 -0500
Received: by mail-gh0-f198.google.com with SMTP id r11so1560795ghr.5
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:39:50 -0800 (PST)
In-Reply-To: <1360978480.19353.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 5:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-02-15 at 17:06 -0800, Pravin B Shelar wrote:
>
>> +     /* segment inner packet. */
>> +     segs = skb_mac_gso_segment(skb, skb->dev->hw_enc_features);
>> +     if (!segs || IS_ERR(segs))
>> +             goto out;
>> +
>
> It seems that hw_enc_features is 0 for all devices.
>
right.

> We should at least inherit NETIF_F_SG
>
ok.

> (and presumably netdev_fix_features() should not remove NETIF_F_SG if
> CSUM is not supported, as we now copy the data _if_ needed in
> skb_checksum_help())
>
yes, that is useful. I have separate patch to kill this dependency, I
will sent it.

Thanks.
