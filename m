From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH -next 2/2] virtio_net: Read the advised MTU
Date: Thu, 02 Jun 2016 13:10:25 -0400
Message-ID: <f7teg8fseim.fsf@redhat.com>
References: <1464882211-18723-1-git-send-email-aconole@redhat.com>
	<1464882211-18723-3-git-send-email-aconole@redhat.com>
	<20160602191632-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602191632-mutt-send-email-mst@redhat.com> (Michael
	S. Tsirkin's message of "Thu, 2 Jun 2016 19:16:57 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:

> On Thu, Jun 02, 2016 at 11:43:31AM -0400, Aaron Conole wrote:
>> This patch checks the feature bit for the VIRTIO_NET_F_MTU feature. If it
>> exists, read the advised MTU and use it.
>> 
>> No proper error handling is provided for the case where a user changes the
>> negotiated MTU. A future commit will add proper error handling. Instead, a
>> warning is emitted if the guest changes the device MTU after previously
>> being given advice.
>
> I don't see a warning and I don't think it's needed.
> Patch is ok commit log isn't.

Okay, I'll fix it when I submit v2.

>> Signed-off-by: Aaron Conole <aconole@redhat.com>
>> ---
>>  drivers/net/virtio_net.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>> 
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index e0638e5..ef5ee01 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1896,6 +1896,12 @@ static int virtnet_probe(struct virtio_device *vdev)
>>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>>  		vi->has_cvq = true;
>>  
>> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
>> +		dev->mtu = virtio_cread16(vdev,
>> +					  offsetof(struct virtio_net_config,
>> +						   mtu));
>> +	}
>> +
>>  	if (vi->any_header_sg)
>>  		dev->needed_headroom = vi->hdr_len;
>>  
>> @@ -2067,6 +2073,7 @@ static unsigned int features[] = {
>>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
>>  	VIRTIO_NET_F_CTRL_MAC_ADDR,
>>  	VIRTIO_F_ANY_LAYOUT,
>> +	VIRTIO_NET_F_MTU,
>>  };
>>  
>>  static struct virtio_driver virtio_net_driver = {
>> -- 
>> 2.5.5
