From: Aaron Conole <aconole@redhat.com>
Subject: Re: [RFC v2 -next 2/2] virtio_net: Read the advised MTU
Date: Thu, 17 Mar 2016 17:15:36 -0400
Message-ID: <f7tbn6cx0uf.fsf@redhat.com>
References: <1458075853-14789-1-git-send-email-aconole@redhat.com>
	<1458075853-14789-3-git-send-email-aconole@redhat.com>
	<56E9699A.9030908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <56E9699A.9030908@cogentembedded.com> (Sergei Shtylyov's message
	of "Wed, 16 Mar 2016 17:11:38 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

> Hello.
>
> On 3/16/2016 12:04 AM, Aaron Conole wrote:
>
>> This patch checks the feature bit for the VIRTIO_NET_F_MTU feature. If it
>> exists, read the advised MTU and use it.
>>
>> No proper error handling is provided for the case where a user changes the
>> negotiated MTU. A future commit will add proper error handling. Instead, a
>> warning is emitted if the guest changes the device MTU after previously
>> being given advice.
>>
>> Signed-off-by: Aaron Conole <aconole@bytheb.org>
>> ---
>> v2:
>> * Whitespace cleanup in the last hunk
>> * Code style change around the pr_warn
>> * Additional test for mtu change before printing warning
>>
>>   drivers/net/virtio_net.c | 12 ++++++++++++
>>   1 file changed, 12 insertions(+)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 767ab11..429fe01 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
> [...]
>> @@ -1390,8 +1391,11 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
>>
>>   static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>>   {
>> +	struct virtnet_info *vi = netdev_priv(dev);
>>   	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
>>   		return -EINVAL;
>> +	if ((vi->negotiated_mtu) && (dev->mtu != new_mtu))
>
>    Inner parens not needed, please be consistent with the code above.

Okay, I will do that.

Thanks so much for the review (again), Sergei!

-Aaron

> [...]
>
> MBR, Sergei
