From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 3/6] bridge: simplify the
 stp_state_store by calling store_bridge_parm
Date: Wed, 06 Apr 2016 16:10:43 -0400 (EDT)
Message-ID: <20160406.161043.260012491646006960.davem@davemloft.net>
References: <6197a35a2eb6df2caf90edcbf1b49da12077f659.1459827115.git.lucien.xin@gmail.com>
	<baf4788b6ac529a2132ace735fc1caf4989307da.1459827115.git.lucien.xin@gmail.com>
	<5703483D.80109@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5703483D.80109@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 5 Apr 2016 14:08:13 +0900

> On 2016/04/05 12:32, Xin Long wrote:
>> There are some repetitive codes in stp_state_store, we can remove
>> them by calling store_bridge_parm.
>> 
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/bridge/br_sysfs_br.c | 24 +++++++-----------------
>>  1 file changed, 7 insertions(+), 17 deletions(-)
>> 
>> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
>> index 137cd3b..9918763 100644
>> --- a/net/bridge/br_sysfs_br.c
>> +++ b/net/bridge/br_sysfs_br.c
>> @@ -128,27 +128,17 @@ static ssize_t stp_state_show(struct device *d,
>>  }
>>  
>>  
>> +static int set_stp_state(struct net_bridge *br, unsigned long val)
>> +{
> 
> You forgot to add rtnl lock here?
> The missing lock is restored in patch 4, but at this point bisect could
> break..

Agreed, this has to be fixed.
