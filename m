From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V5 5/5] virtio_net: support negotiating the number
	of queues through ctrl vq
Date: Fri, 06 Jul 2012 17:26:45 +0800
Message-ID: <4FF6AF55.9080908@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-6-git-send-email-jasowang@redhat.com>
	<1341492679.18786.18.camel@lappy> <4FF65966.9040600@redhat.com>
	<20120705233816.3ec0b827@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, mashirle@us.ibm.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	Sasha Levin <levinsasha928@gmail.com>, jwhan@filewood.snu.ac.kr,
	sri@us.ibm.com, davem@davemloft.net, tahm@linux.vnet.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120705233816.3ec0b827@nehalam.linuxnetplumber.net>
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

On 07/06/2012 02:38 PM, Stephen Hemminger wrote:
> On Fri, 06 Jul 2012 11:20:06 +0800
> Jason Wang<jasowang@redhat.com>  wrote:
>
>> On 07/05/2012 08:51 PM, Sasha Levin wrote:
>>> On Thu, 2012-07-05 at 18:29 +0800, Jason Wang wrote:
>>>> @@ -1387,6 +1404,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>>>>           if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>>>>                   vi->has_cvq = true;
>>>>
>>>> +       /* Use single tx/rx queue pair as default */
>>>> +       vi->num_queue_pairs = 1;
>>>> +       vi->total_queue_pairs = num_queue_pairs;
>>> The code is using this "default" even if the amount of queue pairs it
>>> wants was specified during initialization. This basically limits any
>>> device to use 1 pair when starting up.
>>>
>> Yes, currently the virtio-net driver would use 1 txq/txq by default
>> since multiqueue may not outperform in all kinds of workload. So it's
>> better to keep it as default and let user enable multiqueue by ethtool -L.
>>
> I would prefer that the driver sized number of queues based on number
> of online CPU's. That is what real hardware does. What kind of workload
> are you doing? If it is some DBMS benchmark then maybe the issue is that
> some CPU's need to be reserved.

I run rr and stream test of netperf, and multiqueue shows improvement on 
rr test and regression on small packet transmission in stream test. For 
small packet transmission, multiqueue tends to send much more small 
packets which also increase the cpu utilization. I suspect multiqueue is 
faster and tcp does not merger big enough packet to send, but may need 
more think.
