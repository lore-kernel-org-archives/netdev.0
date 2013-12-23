From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 09/21] batman-adv: slight optimization of addr compare
Date: Mon, 23 Dec 2013 17:10:34 +0800
Message-ID: <52B7FE0A.7000009@huawei.com>
References: <52B7C5C5.2050304@huawei.com> <52B7F853.8050806@meshcoding.com> <1387789163.22671.62.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	"David S. Miller" <davem@davemloft.net>,
	<b.a.t.m.a.n@lists.open-mesh.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387789163.22671.62.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/23 16:59, Joe Perches wrote:
> On Mon, 2013-12-23 at 09:46 +0100, Antonio Quartulli wrote:
>> On 23/12/13 06:10, Ding Tianhong wrote:
>>
>> [...]
>>
>>> --- a/net/batman-adv/originator.c
>>> +++ b/net/batman-adv/originator.c
>>> @@ -41,7 +41,7 @@ int batadv_compare_orig(const struct hlist_node *node, const void *data2)
>>>  	const void *data1 = container_of(node, struct batadv_orig_node,
>>>  					 hash_entry);
>>>  
>>> -	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
>>> +	return ether_addr_equal_unaligned(data1, data2) ? 1 : 0;
>>
>> ether_addr_equal_unaligned() returns a bool value which is implicitly
>> converted to 1 or 0: there is no need for the ternary if anymore.
> 
> Should these use batadv_compare_eth?
> 
> 

Yes, and need to remove the checks for return value.

Regards
Ding 

> 
> 
