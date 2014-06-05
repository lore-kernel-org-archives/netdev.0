From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next] bridge: Fix incorrect judgment of promisc
Date: Thu, 05 Jun 2014 22:05:52 +0900
Message-ID: <53906B30.7080907@lab.ntt.co.jp>
References: <1401965851-6449-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <063D6719AE5E284EB5DD2968C1650D6D17257C08@AcuExch.aculab.com> <539052C0.2090409@lab.ntt.co.jp> <063D6719AE5E284EB5DD2968C1650D6D17257D43@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:44932 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaFENGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 09:06:11 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17257D43@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/06/05 21:55), David Laight wrote:
> From: Toshiaki Makita
>> (2014/06/05 20:03), David Laight wrote:
>>> From: Toshiaki Makita
>>>> br_manage_promisc() incorrectly expects br_auto_port() to return only 0
>>>> or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
>>>>
>>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>> ---
>>>>  net/bridge/br_if.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>>>> index a08d2b8..6a07a40 100644
>>>> --- a/net/bridge/br_if.c
>>>> +++ b/net/bridge/br_if.c
>>>> @@ -153,7 +153,7 @@ void br_manage_promisc(struct net_bridge *br)
>>>>  			 * This lets us disable promiscuous mode and write
>>>>  			 * this config to hw.
>>>>  			 */
>>>> -			if (br->auto_cnt <= br_auto_port(p))
>>>> +			if (br->auto_cnt <= !!br_auto_port(p))
>>>>  				br_port_clear_promisc(p);
>>>>  			else
>>>>  				br_port_set_promisc(p);
>>>
>>> Why not the less confusing:
>>> 			if (br->auto_cnt || br_auto_port(p))
>>> and reverse the then/else lines?
>>
>> I'm respecting the original style, but I'm not particular about this style.
>> I'll make less confusing one, thanks :)
>>
>> (Your suggested condition is not exactly the same as current one, even
>> if reversing if/else. v2 will be different than it. Anyway, thanks.)
> 
> A quick truth table:
> 	auto_cnt	auto_port	set/clear
> 		0		0	clear
> 		0		1	clear
> 		1		0	set
> 		1		1	clear
> 		2+		0/1	clear

The last line should be set.

Thanks,
Toshiaki Makita

> 
> So you want:
> 	if (br->auto_cnt && !br_auto_port(p))
> 		br_port_set_promisc(p);
> 	else
> 		br_port_clear_promisc(p);
> 
> Does seem like a strange condition.
> 
> 	David
