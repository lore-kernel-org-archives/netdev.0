From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 4/4] bridge: Support 802.1ad vlan
	filtering
Date: Tue, 10 Jun 2014 16:15:35 +0900
Message-ID: <5396B097.8050100@lab.ntt.co.jp>
References: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1402313687-28067-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<5396564A.5040108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5396564A.5040108@gmail.com>
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

(2014/06/10 9:50), Vlad Yasevich wrote:
> On 06/09/2014 07:34 AM, Toshiaki Makita wrote:
>> This enables us to change the vlan protocol for vlan filtering.
>> We come to be able to filter frames on the basis of 802.1ad vlan tags
>> through a bridge.
>>
>> This also changes br->group_addr if it has not been set by user.
>> This is needed for an 802.1ad bridge.
>> (See IEEE 802.1Q-2011 8.13.5.)
>>
>> To change the vlan protocol, write a protocol in sysfs:
>> # echo 0x88a8 > /sys/class/net/br0/bridge/vlan_protocol
>>
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> ---
>>  net/bridge/br_private.h  |  2 ++
>>  net/bridge/br_sysfs_br.c | 18 +++++++++++
>>  net/bridge/br_vlan.c     | 81 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 101 insertions(+)
>>
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 65204c2..3c5b23b 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -246,6 +246,7 @@ struct net_bridge
>>  	unsigned long			bridge_forward_delay;
>>  
>>  	u8				group_addr[ETH_ALEN];
>> +	unsigned char			group_addr_set;
> 
> nit:  can be bool since you just use true/false.

I'm not sure which is better in struct... but maybe it's more explicit.
will change it in v2.

Thanks,
Toshiaki Makita
