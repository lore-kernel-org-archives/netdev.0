From: Jason Wang <jasowang@redhat.com>
Subject: Re: [rfc net-next v6 3/3] virtio-net: change the number of queues
	through ethtool
Date: Mon, 19 Nov 2012 14:22:40 +0800
Message-ID: <50A9D030.7070100@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<1351591403-23065-4-git-send-email-jasowang@redhat.com>
	<871ug9yls5.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <871ug9yls5.fsf@rustcorp.com.au>
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

On 11/05/2012 07:46 AM, Rusty Russell wrote:
> Jason Wang <jasowang@redhat.com> writes:
>> This patch implement the {set|get}_channels method of ethool to allow user to
>> change the number of queues dymaically when the device is running. This would
>> let the user to tune the device for specific applications.
> ...
>> +	/* Only two modes were support currently */
>> +	if (queue_pairs == 0)
>> +		return -EINVAL;
>> +	if (queue_pairs != vi->total_queue_pairs - 1 && queue_pairs != 1)
>> +		return -EINVAL;
> OK, so you let them do all or nothing, but this three-way test is
> pretty unclear.

True, looks like the first check could be removed.
>
> In fact, the whole total_queue_pairs/num_queue_pairs thing is weird (and
> uncommented).  I think for "total" you mean "max"; the maximum possible
> queue pair number.

Yes, "total" means "max", will add a comment or change the name to 
max_queue_pairs/current_queue_pairs.
>
> Let me go back and review the previous patch again...
>
> Cheers,
> Rusty.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
