From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] net: fix possible wrong checksum generation
Date: Tue, 29 Jan 2013 11:30:10 -0800
Message-ID: <CALnjE+o_oHB9aoJApkjut=iJ0uHCHGQMguyeP0WNmTgUZgrQEg@mail.gmail.com>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	<1359070199.12374.2557.camel@edumazet-glaptop>
	<CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
	<1359077664.12374.2887.camel@edumazet-glaptop>
	<CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
	<1359143538.12374.3379.camel@edumazet-glaptop>
	<1359182077.5222.132.camel@edumazet-glaptop>
	<1359398148.2721.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:44697 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750913Ab3A2TaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:30:11 -0500
Received: by mail-gh0-f200.google.com with SMTP id 10so1036999ghy.7
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 11:30:10 -0800 (PST)
In-Reply-To: <1359398148.2721.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2013 at 10:35 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2013-01-25 at 22:34 -0800, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Pravin Shelar mentioned that GSO could potentially generate
>> wrong TX checksum if skb has fragments that are overwritten
>> by the user between the checksum computation and transmit.
>>
>> He suggested to linearize skbs but this extra copy can be
>> avoided for normal tcp skbs cooked by tcp_sendmsg().
>>
>> This patch introduces a new SKB_GSO_SHARED_FRAG flag, set
>> in skb_shinfo(skb)->gso_type if at least one frag can be
>> modified by the user.
> [...]
>
> Again, this needs a net device feature, doesn't it?  net_gso_ok() should
> allow hardware checksum/segmentation offload of such packets, and it
> won't if there is this new GSO flag with no corresponding net device
> feature.
>

I am not sure if this flag need to be a GSO type. There is possibility
of having such a page fragment in non GSO packets.
we could have this flag in skb_shinfo(skb)->tx_flags.

Thanks,
Pravin.
