From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 16:47:09 +0200
Message-ID: <57EA866D.9050507@iogearbox.net>
References: <20160927.015606.437705429903770747.davem@davemloft.net>    <20160927110711.12555f4e@pixies>        <57EA4C66.8070907@iogearbox.net>        <20160927.094441.1957543068015677016.davem@davemloft.net> <20160927171804.5288347d@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45093 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcI0OrW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:47:22 -0400
In-Reply-To: <20160927171804.5288347d@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2016 04:18 PM, Shmulik Ladkani wrote:
> On Tue, 27 Sep 2016 09:44:41 -0400 (EDT), davem@davemloft.net wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Tue, 27 Sep 2016 12:39:34 +0200
>>
>>> Any reason why dev_forward_skb() is not preferred over direct
>>> netif_receive_skb() you're using? It would, for example, implicitly
>>> assure that pkt_type is always PACKET_HOST, etc.
>>
>> dev_forward_skb() will pull the ethernet header.
>>
>> And since a direct call to netif_receive_skb() will not, one of these
>> two choices won't work properly.
>
> In the patch, I'm issuing a skb_pull_rcsum() prior the netif_receive_skb,
> snip:
>
[...]
>
> Existing *egress* mir/red already supported pairing two non-eth devices.
> Therefore I allow it for the new *ingress* mir/red as well.
[...]

Yeah, makes sense then. Should skb->pkt_type become an issue, you might
probably just use act_skbedit for such cases.
