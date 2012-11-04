From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [rfc net-next v6 3/3] virtio-net: change the number of queues
	through ethtool
Date: Mon, 05 Nov 2012 10:16:02 +1030
Message-ID: <871ug9yls5.fsf@rustcorp.com.au>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<1351591403-23065-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com, davem@davemloft.net,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1351591403-23065-4-git-send-email-jasowang@redhat.com>
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

Jason Wang <jasowang@redhat.com> writes:
> This patch implement the {set|get}_channels method of ethool to allow user to
> change the number of queues dymaically when the device is running. This would
> let the user to tune the device for specific applications.
...
> +	/* Only two modes were support currently */
> +	if (queue_pairs == 0)
> +		return -EINVAL;
> +	if (queue_pairs != vi->total_queue_pairs - 1 && queue_pairs != 1)
> +		return -EINVAL;

OK, so you let them do all or nothing, but this three-way test is
pretty unclear.

In fact, the whole total_queue_pairs/num_queue_pairs thing is weird (and
uncommented).  I think for "total" you mean "max"; the maximum possible
queue pair number.

Let me go back and review the previous patch again...

Cheers,
Rusty.
