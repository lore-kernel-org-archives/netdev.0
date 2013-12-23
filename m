From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 12/21] bridge: slight optimization of addr
	compare
Date: Mon, 23 Dec 2013 16:38:01 +0800
Message-ID: <52B7F669.8080207@huawei.com>
References: <52B7C5D5.2040202@huawei.com>
	<1387787627.1797.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1387787627.1797.10.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2013/12/23 16:33, Toshiaki Makita wrote:
> On Mon, 2013-12-23 at 13:10 +0800, Ding Tianhong wrote:
>> Use the recently added and possibly more efficient
>> ether_addr_equal_unaligned to instead of memcmp.
>>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: David Miller <davem@davemloft.net>
>> Cc: bridge@lists.linux-foundation.org
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  net/bridge/br_stp_if.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
>> index 656a6f3..04217d1 100644
>> --- a/net/bridge/br_stp_if.c
>> +++ b/net/bridge/br_stp_if.c
>> @@ -229,7 +229,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
>>  
>>  	list_for_each_entry(p, &br->port_list, list) {
>>  		if (addr == br_mac_zero ||
>> -		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
>> +		    !ether_addr_equal_unaligned(p->dev->dev_addr, addr) < 0)
>>  			addr = p->dev->dev_addr;
>>  
>>  	}
> 
> We cannot do this change.
> !ether_addr_equal() isn't identical to memcmp().
> memcmp() can return negative value but ether_addr_equal() cannot.
> br_stp_recalculate_bridge_id() is searching the smallest address among
> its ports. This change breaks it.
> 
> Thanks,
> Toshiaki Makita

Yes, I miss it, the negative value is useful here, thanks for point out.

Regards
Ding

> 
> 
> 
