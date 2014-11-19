From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] packet: make packet_snd fail on len smaller than
 l2 header
Date: Wed, 19 Nov 2014 13:07:08 -0500
Message-ID: <CA+FuTSdmTrBoWJoDmuGhSVRRp9cmZC2GEK-Scqac26W+sSBA6A@mail.gmail.com>
References: <1416416165-24697-1-git-send-email-willemb@google.com> <546CD087.9070003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:38028 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbaKSSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:07:39 -0500
Received: by mail-qa0-f45.google.com with SMTP id x12so771142qac.32
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 10:07:39 -0800 (PST)
In-Reply-To: <546CD087.9070003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> ---
>>   net/packet/af_packet.c | 30 ++++++++++++++++++++++--------
>>   1 file changed, 22 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 4cd13d8..0d3cb44 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -2095,6 +2095,18 @@ static void tpacket_destruct_skb(struct sk_buff
>> *skb)
>>         sock_wfree(skb);
>>   }
>>
>> +static bool ll_header_truncated(int len, struct net_device *dev)
>> +{
>
>
> const struct net_device *dev
>
> [ if at it, I'd perhaps also swap the arg order ]

Thanks, Daniel. I'll resubmit with both changes.
