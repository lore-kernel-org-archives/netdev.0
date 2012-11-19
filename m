From: Jason Wang <jasowang@redhat.com>
Subject: Re: [rfc net-next v6 2/3] virtio_net: multiqueue support
Date: Mon, 19 Nov 2012 14:18:24 +0800
Message-ID: <50A9CF30.9090503@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<1351591403-23065-3-git-send-email-jasowang@redhat.com>
	<874nl5yn4k.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <874nl5yn4k.fsf@rustcorp.com.au>
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

On 11/05/2012 07:16 AM, Rusty Russell wrote:
> Jason Wang <jasowang@redhat.com> writes:
>> This addes multiqueue support to virtio_net driver. There's two mode supported:
>> single queue pair mode and multiple queue pairs mode. An obvious
>> difference compared with a physical mq card is that virtio-net reserve
>> first two virtqueues when it is working in multiqueue mode, this is
>> used for implementing adaptive mode switching in the future. The
>> virtqueues that were in both mq and sq mode were initialized and only
>> one queue pair (single queue mode) were used at default. User could
>> use ethtool -L to switch to multiqueue mode withe the next patch.
> Hi Jason,
>
>          This first patch looks good, but conflates three things
> together:
> (1) Separate per-queue structures from struct virtnet_info to allow
>      multiple queues.  This is the mechanical part of the patch.
> (2) An annotation bugfix, see below.
> (3) Enabling mq using a new feature and negotiation.

Hi Rusty:

Sorry for the late response, just back from vacation.

For 1 and 3, I will split the patch as you suggested.
For 2, will fix it.

Thanks
>
>> @@ -700,7 +767,8 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
>>   	unsigned int start;
>>   
>>   	for_each_possible_cpu(cpu) {
>> -		struct virtnet_stats *stats = per_cpu_ptr(vi->stats, cpu);
>> +		struct virtnet_stats __percpu *stats
>> +			= per_cpu_ptr(vi->stats, cpu);
>>   		u64 tpackets, tbytes, rpackets, rbytes;
>>   
>>   		do {
> Cheers,
> Rusty.
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
