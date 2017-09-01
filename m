From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: switchdev: Clear forward mark when
 transmitting packet
Date: Fri, 1 Sep 2017 15:03:33 +0300
Message-ID: <a2a82e24-43f1-02d6-fdfb-db3cdcbaf63a@cumulusnetworks.com>
References: <20170901092225.31597-1-idosch@mellanox.com>
	<0384baf6-0786-2d07-8919-fdd1ca5d88eb@cumulusnetworks.com>
	<20170901120120.GA1962@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mlxsw@mellanox.com, yotamg@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Ido Schimmel <idosch@mellanox.com>, jiri@mellanox.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170901120120.GA1962@nanopsycho>
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

On 01/09/17 15:01, Jiri Pirko wrote:
> Fri, Sep 01, 2017 at 01:45:15PM CEST, nikolay@cumulusnetworks.com wrote:
>> On 01/09/17 12:22, Ido Schimmel wrote:
>>> Commit 6bc506b4fb06 ("bridge: switchdev: Add forward mark support for
>>> stacked devices") added the 'offload_fwd_mark' bit to the skb in order
>>> to allow drivers to indicate to the bridge driver that they already
>>> forwarded the packet in L2.
>>>
>>> In case the bit is set, before transmitting the packet from each port,
>>> the port's mark is compared with the mark stored in the skb's control
>>> block. If both marks are equal, we know the packet arrived from a switch
>>> device that already forwarded the packet and it's not re-transmitted.
>>>
>>> However, if the packet is transmitted from the bridge device itself
>>> (e.g., br0), we should clear the 'offload_fwd_mark' bit as the mark
>>> stored in the skb's control block isn't valid.
>>>
>>> This scenario can happen in rare cases where a packet was trapped during
>>> L3 forwarding and forwarded by the kernel to a bridge device.
>>>
>>> Fixes: 6bc506b4fb06 ("bridge: switchdev: Add forward mark support for stacked devices")
>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>>> Reported-by: Yotam Gigi <yotamg@mellanox.com>
>>> Tested-by: Yotam Gigi <yotamg@mellanox.com>
>>> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  net/bridge/br_device.c | 3 +++
>>>  1 file changed, 3 insertions(+)
>>>
>>> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
>>> index 861ae2a165f4..5a7be3bddfa9 100644
>>> --- a/net/bridge/br_device.c
>>> +++ b/net/bridge/br_device.c
>>> @@ -53,6 +53,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>>>  	brstats->tx_bytes += skb->len;
>>>  	u64_stats_update_end(&brstats->syncp);
>>>  
>>> +#ifdef CONFIG_NET_SWITCHDEV
>>> +	skb->offload_fwd_mark = 0;
>>> +#endif
>>>  	BR_INPUT_SKB_CB(skb)->brdev = dev;
>>>  
>>>  	skb_reset_mac_header(skb);
>>>
>>
>> Good catch, just one minor nit since there is already an ifdef
>> switchdev/else in br_private.h, why not make this a helper and avoid the
>> ifdef/endif in here ? Currently there is no ifdef switchdev anywhere else.
> 
> I think it would be better to convert this to a helper in -net-next and
> take the patch as it is for -net
> 

Either way is fine I guess, it's just more work for something as simple. :-)

Whichever way you choose,

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
