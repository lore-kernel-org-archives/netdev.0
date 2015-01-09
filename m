From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net-next] bridge: Add ability to enable TSO
Date: Fri, 09 Jan 2015 15:22:37 +0900
Message-ID: <54AF73AD.4000008@lab.ntt.co.jp>
References: <1420780600-11313-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1138400428.6686751.1420782286490.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1138400428.6686751.1420782286490.JavaMail.zimbra@redhat.com>
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

On 2015/01/09 14:44, Pankaj Gupta wrote:
> 
>>
>> Currently a bridge device turns off TSO feature if no bridge ports
>> support it. We can always enable it, since packets can be segmented on
>> ports by software as well as on the bridge device.
>> This will reduce the number of packets processed in the bridge.
>>
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> ---
>> v2: Use an existing helper function.
>>
>>  net/bridge/br_if.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index ed307db..81e49fb 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -424,6 +424,7 @@ netdev_features_t br_features_recompute(struct net_bridge
>> *br,
>>  		features = netdev_increment_features(features,
>>  						     p->dev->features, mask);
>>  	}
>> +	features = netdev_add_tso_features(features, mask);
> 
> Just a doubt. Are we inducing latency if source has traffic at very low rate.
> I mean by default do we need it?

Is your concern tcp_tso_should_defer() in tcp_write_xmit()?
If so, since TSO packet is created by GSO even without this patch, this
should not increase latency there.
This patch just delays the point of software segmentation from the
bridge device to its port.

Thanks,
Toshiaki Makita
