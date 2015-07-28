From: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 28 Jul 2015 21:16:37 +0000
Message-ID: <55B7F132.40006@alliedtelesis.co.nz>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
 <20150728125157.10917b0b@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:51716 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbbG1VQp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 17:16:45 -0400
In-Reply-To: <20150728125157.10917b0b@urahara>
Content-Language: en-US
Content-ID: <25DAFD2B24EC26428E1B8EF156551881@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 07/29/2015 07:51 AM, Stephen Hemminger wrote:
> On Tue, 28 Jul 2015 02:27:57 +0000
> Richard Laing <Richard.Laing@alliedtelesis.co.nz> wrote:
>
>> From: Richard Laing <richard.laing@alliedtelesis.co.nz>
>>
>> Enable flow-based ECMP.
>>
>> Currently if equal-cost multipath is enabled the kernel chooses between
>> equal cost paths for each matching packet, essentially packets are
>> round-robined between the routes. This means that packets from a single
>> flow can traverse different routes. If one of the routes experiences
>> congestion this can result in delayed or out of order packets arriving
>> at the destination.
>>
>> This patch allows packets to be routed based on their
>> flow - packets in the same flow will always use the same route. This
>> prevents out of order packets. There are other issues with round-robin
>> based ECMP routing related to variable path MTU handling and debugging.
>> See RFC2991 for more details on the problems associated with packet
>> based ECMP routing.
>>
>> This patch relies on the skb hash value to select between routes. The
>> selection uses a hash-threshold algorithm (see RFC2992).
>>
>> Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>
> ECMP needs some work, glad to see someone has started again.
> A little bit of history, the original ECMP algorithm selection code was dropped years ago
> because it was buggy. The API was good, but the implemenation had problems.
>
> Somewhere in my dustbin, I have some patches from internal stuff that allows
> selecting the algorithm at runtime.
>
> Your implementation makes it a compile time choice. Although this is good
> for testing, it really needs to be a sysctl or route attribute to be
> useful in a distro environment.
>
> As others said, your mailer is mangling the lines by wrapping.

Thanks Stephen, not sure what happened with the formatting, I'll try and 
find out. I will look at a sysctl option to enable the flow based ECMP 
option.

Cheers
Richard

-- 
Richard Laing
Software Team Leader
Allied Telesis Labs| 27 Nazareth Ave | Christchurch 8024 | New Zealand
Phone: +64 3 339 9248
Web: www.alliedtelesis.com
