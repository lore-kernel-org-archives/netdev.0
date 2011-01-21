From: Ben Greear <greearb@candelatech.com>
Subject: Re: Using ethernet device as efficient small packet generator
Date: Fri, 21 Jan 2011 05:38:34 -0800
Message-ID: <4D398C5A.90808@candelatech.com>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>    <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>    <1295610709.2601.35.camel@edumazet-laptop> <37bfb9ca79c2325ec4b70033f509200a.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	Jon Zhou <jon.zhou@jdsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38508 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab1AUNis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 08:38:48 -0500
In-Reply-To: <37bfb9ca79c2325ec4b70033f509200a.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2011 04:12 AM, juice wrote:
>> Le vendredi 21 janvier 2011 =C3  13:44 +0200, juice a =C3=A9crit :
>>
>>
>> You should try
>>
>> CLONE_SKB=3D"clone_skb 10"
>> ...
>> pgset "$CLONE_SKB"
>>
>>
>> Because I suspect you hit a performance problem on skb
>> allocation/filling/use/freeing
>
> Actually, that makes the performance worse:
> (Now I tried it with kernel 2.6.37, which is currently running)

Maybe try clone-skb of 1000 or so.  It zero's it's memory when
allocating a packet which can be quite expensive.

Also note that the Ethernet inter-frame gap isn't accounted for in
the BPS, but it is a significant amount of the total bandwidth
when using 64-byte packets.
You are pushing a bit more than half of the theoretical limit of
around 1,400,000 64-byte packets per second for 1Gbps ethernet.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
