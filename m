From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 1/2] net: Allow modules to use
	is_skb_forwardable
Date: Wed, 26 Mar 2014 20:50:47 -0400
Message-ID: <533375E7.80403@redhat.com>
References: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>	<1395849627-15711-3-git-send-email-vyasevic@redhat.com>
	<20140326143519.72ea3cc6@samsung-9>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140326143519.72ea3cc6@samsung-9>
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

On 03/26/2014 05:35 PM, Stephen Hemminger wrote:
> On Wed, 26 Mar 2014 12:00:26 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>  include/linux/netdevice.h | 1 +
>>  net/core/dev.c            | 3 ++-
>>  2 files changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index e8eeebd..d855794 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -2551,6 +2551,7 @@ int dev_get_phys_port_id(struct net_device *dev,
>>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>>  			struct netdev_queue *txq);
>>  int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
>> +bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
>>  
>>  extern int		netdev_budget;
>>  
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index b1b0c8d..a98f7fa 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1645,7 +1645,7 @@ static inline void net_timestamp_set(struct sk_buff *skb)
>>  			__net_timestamp(SKB);		\
>>  	}						\
>>  
>> -static inline bool is_skb_forwardable(struct net_device *dev,
>> +bool is_skb_forwardable(struct net_device *dev,
>>  				      struct sk_buff *skb)
>>  {
>>  	unsigned int len;
>> @@ -1665,6 +1665,7 @@ static inline bool is_skb_forwardable(struct net_device *dev,
>>  
>>  	return false;
>>  }
>> +EXPORT_SYMBOL_GPL(is_skb_forwardable);
>>  
>>  /**
>>   * dev_forward_skb - loopback an skb to another netif
> 
> This will allow an arbitrary 1522 byte frame to be forwarded.
> Not sure if this ok.
> 

We already do that for macvlan/veth.

-vlad
