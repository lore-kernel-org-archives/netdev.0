From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Thu, 13 Dec 2012 17:13:56 +0100
Message-ID: <50C9FEC4.5050804@onera.fr>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr> <20121213132916.GB10703@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:43167 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab2LMQQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 11:16:35 -0500
In-Reply-To: <20121213132916.GB10703@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/13/2012 02:29 PM, Richard Cochran wrote:
> On Wed, Dec 12, 2012 at 04:29:25PM +0100, Paul Chavent wrote:
>> This patch allow to generate tx timestamps of packets sent by the packet mmap interface.
>>
>> Actually, you can't get tx timestamps with the sample code below.
>>
>> I wonder if my current implementation is good. And if not, how should i get the timestamps ?
>
> In order for time stamps to appear, somebody has to call
> skb_tx_timestamp() ...
Yes. "Somebody" means "the hardware driver" after completing xmit. 
That's true ?

>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index e639645..948748b 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1857,6 +1857,10 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>>   	void *data;
>>   	int err;
>>
>> +	err = sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
 >
 > and this call is only setting some flags.

Yes, it only sets some flags. I thought that those flags was required by 
the skb_tx_timestamp() in order to make the appropriate timestamping 
(hardware, software, etc).

So in order to have tx timestamp that work, both calls are needed ?

Why sock_tx_timestamp is called in packet_fill_skb and 
packet_sendmsg_spkt and not in tpacket_fill_skb ?
Why i can retrieve timestamps when i add this call ?

>
> HTH,
> Richard
>
Thank for your help.

Paul.
