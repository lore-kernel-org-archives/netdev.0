From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 0/4] [RFC rev2] Implement multiqueue (RX & TX) virtio-net
Date: Wed, 13 Apr 2011 15:00:11 +0300
Message-ID: <4DA5904B.9090006@redhat.com>
References: <20110405150826.20501.39679.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com,
	eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	horms@verge.net.au, anthony@codemonkey.ws, kvm@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867Ab1DMMAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 08:00:31 -0400
In-Reply-To: <20110405150826.20501.39679.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2011 06:08 PM, Krishna Kumar wrote:
> This patchset implements both RX and TX MQ. Patch against virtio-net,
> vhost and qemu are included.
>
> Changes from rev1:
> -------------------
> 1. vqs are allocated as: rx/tx, rx/tx, rx/tx, etc. Lot of code in
>     guest/host/qemu changes, but code becomes simpler.
> 2. vhost cache align of vhost_dev correctly.
> 3. virtio-net: cleanup properly on errors (eg detach buf for vq>0 as
>     pointed out by Micheal).
> 4. Minor changes:
> 	- Fixed some typos.
> 	- Changed vhost_get_thread_index to use MAX_VHOST_THREADS.
> 	- Removed VIRTIO_MAX_TXQS.
> 	- Changed capability to VIRTIO_NET_F_MULTIQUEUE.
> 	- Modified "numtxqs" in virtnet_info to "num_queue_pairs".
> 	  virtnet_info still has numtxqs as it is more convenient.
> 	- Moved code for VIRTIO_NET_F_CTRL_VLAN into probe function.
> 	- Improve check for return value of virtio_config_val().
> 	- Removed cache align directives in guest as it was redundant.
> 5. "If we have a wrapper to init all vqs, pls add a wrapper to clean up
>      all vqs as well": I haven't done this as some errors are very
>      specific to the failure location (and what was initialized till
>      then). So only those errors are cleaned up using goto's like the
>      rest of the code. I can change in next version if you feel this is
>      still required.
> 6.  "I think we should have free_unused_bufs that handles a single queue,
>      and call it in a loop": I haven't done this as I think the caller wants
>      all rx/tx queues to be cleaned up by calling this function.
>
> TODO's:
> --------
> 1. Reduce vectors for find_vqs().
> 2. Make vhost changes minimal. For now, I have restricted the number of
>     vhost threads to 4. This can be either made unrestricted; or if the
>     userspace vhost works, it can be removed altogether.
>
> Please review and provide feedback. I am travelling a bit in the next
> few days but will respond at the earliest.

Do you have an update to the virtio-pci spec for this?

-- 
error compiling committee.c: too many arguments to function

