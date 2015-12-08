From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] geneve: Fix IPv6 xmit stats update.
Date: Tue, 8 Dec 2015 09:55:58 -0800
Message-ID: <CALnjE+r=Gvh-FD12o-SmPONACs1O9TSzemg37Hk5-5g-hW6afw@mail.gmail.com>
References: <1449544650-6112-1-git-send-email-pshelar@nicira.com>
	<20151208145410.GC3598@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33993 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbbLHRz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:55:58 -0500
Received: by igvg19 with SMTP id g19so106673915igv.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 09:55:58 -0800 (PST)
In-Reply-To: <20151208145410.GC3598@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 6:54 AM, John W. Linville <linville@tuxdriver.com> wrote:
> On Mon, Dec 07, 2015 at 07:17:30PM -0800, Pravin B Shelar wrote:
>> Call to iptunnel_xmit_stats() is not required after udp-tunnel6-xmit.
>> By calling iptunnel_xmit_stats() results in incorrect device stats.
>> Following patch drops this call.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>>  drivers/net/geneve.c |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index de5c30c..c2b79f5 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -967,8 +967,6 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>>       err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
>>                                  &fl6.saddr, &fl6.daddr, prio, ttl,
>>                                  sport, geneve->dst_port, !udp_csum);
>> -
>> -     iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
>>       return NETDEV_TX_OK;
>>
>>  tx_error:
>
> So udp_tunnel_xmit_skb and udp_tunnel6_xmit_skb are different in this
> regard? It seems so -- who knew? :-)
>
> _Should_ they be different in this regard?
>

I am planing on sending a patch to make these APIs consistent.
