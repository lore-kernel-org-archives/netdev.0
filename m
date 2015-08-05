From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: drop NETIF_F_FRAGLIST
Date: Wed, 05 Aug 2015 10:32:02 +0800
Message-ID: <55C175A2.4070706@redhat.com>
References: <1438682145-25986-1-git-send-email-jasowang@redhat.com> <55C09DC4.4070108@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C09DC4.4070108@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/04/2015 07:11 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 8/4/2015 12:55 PM, Jason Wang wrote:
>
>> virtio declares support for NETIF_F_FRAGLIST, but assumes
>> that there are at most MAX_SKB_FRAGS + 2 fragments which isn't
>> always true with a fraglist.
>
>> A longer fraglist in the skb will make the call to skb_to_sgvec overflow
>> the sg array, leading to memory corruption.
>
>> Drop NETIF_F_FRAGLIST so we only get what we can handle.
>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>> The patch is needed for stable.
>> ---
>>   drivers/net/virtio_net.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 7fbca37..2347a73 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1756,9 +1756,9 @@ static int virtnet_probe(struct virtio_device
>> *vdev)
>>       /* Do we support "hardware" checksums? */
>>       if (virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
>>           /* This opens up the world of extra features. */
>> -        dev->hw_features |=
>> NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
>> +        dev->hw_features |= NETIF_F_HW_CSUM|NETIF_F_SG;
>>           if (csum)
>> -            dev->features |=
>> NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
>> +            dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG;
>
>    I'd have added spaces around | to match the style seen below.
>

Ok, will fix this in V2.

>>           if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
>>               dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
>
> MBR, Sergei
>
