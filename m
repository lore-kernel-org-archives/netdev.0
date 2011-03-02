From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy and
 source mac selection mode
Date: Wed, 02 Mar 2011 12:15:47 +0300
Message-ID: <4D6E0AC3.3080305@yandex-team.ru>
References: <20110301223458.GA24403@yandex-team.ru> <20110301152951.646451c6@nehalam> <413.1299034578@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elephant.yandex.ru ([77.88.34.7]:42545 "EHLO elephant.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755922Ab1CBJWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 04:22:21 -0500
In-Reply-To: <413.1299034578@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/02/2011 05:56 AM, Jay Vosburgh wrote:
> Stephen Hemminger<shemminger@vyatta.com>  wrote:
>
>> On Wed, 2 Mar 2011 01:34:58 +0300
>> "Oleg V. Ukhno"<olegu@yandex-team.ru>  wrote:
>>

>>
>> It seems to me the whole bonding policy is getting so complex
>> that the code is a mess. Perhaps it should be somehow linked into
>> existing packet classification or firewall mechanisms.  This would
>> increase the flexibility and reduce the amount of policy code
>> in the bonding driver itself.
>
> 	Hmm.
>
> 	Yes, the number of special case knobs in bonding is getting
> rather large, and there are one or two other proposals in the pipe
> besides this one.
>
> 	It would be handy to be able to do things like run ebtables
> style rules against traffic going in and out of the bond.  Right now
> ebtables is pretty tightly coupled with the bridge, so we'd need to add
> a whole new set of netfilter "bondtables" or something.  Or add hooks
> for ebtables outside of the bridge.
>
> 	For this particular patch, the src-mac business could be handled
> by a netfilter module.  The round-robin hash policy part would probably
> have to stay in bonding.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>

I am sorry, but I disagree with you, although it is possible to use 
ebtables as a general mechanism to alter L2 headers.
It seems to be possible(never did so) to use ebtables for altering 
src-mac field for outgoing packets, but is is done in iptables/ipchains 
manner - with manual configuration - and requires to know all the 
mac-address - interface bindings.
My point in collecting all this stuff in bonding module was :
- make bonding configuration with src-mac subtitution as simple as 
possible, which reduces choice of human error when mantaining 100+ 
server deployments
- make configuration equally simple for any number of slaves and allow 
simple slave addon/removal
- eliminate need for tracking hwaddress changes when replacing network 
cards/server body.
- although I've never really used ebtables in my production, my 
experience with iptables (this may not be true for all cases or may be 
true for lesser part) tells me that using quite complex set of rules to 
analyze and alter packets will introduce excessive CPU and latency 
penalties, which will possibly cause (much?) worse packet reordering as 
it is for this patch.
- one important thing for me (maybe it is not always true) - simplicity 
of debugging any network problems with this kind of port-teaming.



-- 
Best regards,
Oleg Ukhno
