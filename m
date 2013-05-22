From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] bridge: Set vlan_features to allow offloads on
	vlans.
Date: Wed, 22 May 2013 12:39:17 -0400
Message-ID: <519CF4B5.2030504@redhat.com>
References: <1369237590-29871-1-git-send-email-vyasevic@redhat.com>
	<1369239164.2670.13.camel@bwh-desktop.uk.level5networks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1369239164.2670.13.camel@bwh-desktop.uk.level5networks.com>
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

On 05/22/2013 12:12 PM, Ben Hutchings wrote:
> On Wed, 2013-05-22 at 11:46 -0400, Vlad Yasevich wrote:
>> When vlan device is configured on top of the brige, it does
>> not support any offload capabilities because the bridge
>> device does not initiliaze vlan_fatures.  Set vlan_fatures to
>> be equivalent to hw_fatures.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   net/bridge/br_device.c |    1 +
>>   1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
>> index 9673128..126f2c2 100644
>> --- a/net/bridge/br_device.c
>> +++ b/net/bridge/br_device.c
>> @@ -352,6 +352,7 @@ void br_dev_setup(struct net_device *dev)
>>   	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
>>   			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
>>   			   NETIF_F_HW_VLAN_CTAG_TX;
>> +	dev->vlan_features = dev->hw_features;
>
> I think you need to mask out NETIF_F_HW_VLAN_CTAG_TX (although maybe the
> vlan driver should take care of that itself).
>

Yep, you are right.  I guess it would confuse things a bit 802.1ad was
configured on top of the bridge.

I'll fix that.
-vlad

> Ben.
>
>>   	br->dev = dev;
>>   	spin_lock_init(&br->lock);
>
