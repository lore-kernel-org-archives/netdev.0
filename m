From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 3/3] GRE: Add TCP segmentation offload for GRE
Date: Thu, 14 Feb 2013 19:19:29 -0800
Message-ID: <CALnjE+q_P=7fbkwcs8A8YP9H9fdWMVN8Zir3nFixfcEMfNfCwQ@mail.gmail.com>
References: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
	<1360892389.6884.74.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com, mirqus@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:52589 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932322Ab3BODTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 22:19:30 -0500
Received: by mail-ye0-f200.google.com with SMTP id r13so3740643yen.3
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 19:19:30 -0800 (PST)
In-Reply-To: <1360892389.6884.74.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 5:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-02-14 at 11:45 -0800, Pravin B Shelar wrote:
>> Following patch adds GRE protocol offload handler so that
>> skb_gso_segment() can segment GRE packets.
>> SKB GSO CB is added to keep track of total header length so that
>> skb_segment can push entire header. e.g. in case of GRE, skb_segment
>> need to push inner and outer headers to every segment.
>> New NETIF_F_GRE_GSO feature is added for devices which support HW
>> GRE TSO offload. Currently none of devices support it therefore GRE GSO
>> always fall backs to software GSO.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> Fixed according to comments from Jesse and Eric.
>> v2-v3:
>>  - Use device features to segment inner packet.
>>  - Moved skb_mac_gso_segment to separate patch.
>>  - simplified gre_gso_segment().
>>  - Added NETIF_F_GRE_GSO feature.
>>
>> v1-v2:
>>  - Factored a MAC layer handler out of skb_gso_segment().
>>  - Eliminated copy operation from gre_gso_segment().
>>  - Refresh header pointer after pskb_may_pull().
>> ---
>
> Seems very good to me, thanks !
>
> The only thing that puzzles me is the ip_select_ident() in
> ipgre_tunnel_xmit()
>
> Do we care of the IP identifiers being 0, 1, 2, 3, ... on the outer
> headers ?
>
> Without TSO, we are using 0 IP identifiers (DF being set)
>
right. I will keep id as zero for all cases.

> Also if we can't unclone the skb in handle_offloads(), we should
> increment tx_dropped or tx_errors.
>
ok.

>
>
>
