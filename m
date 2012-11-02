From: Max Krasnyansky <maxk@qti.qualcomm.com>
Subject: Re: [net-next v5 0/7] Multiqueue support in tuntap
Date: Thu, 1 Nov 2012 19:18:11 -0700
Message-ID: <50932D63.3080308@qti.qualcomm.com>
References: <1351748762-3455-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <mst@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <edumazet@google.com>,
	<krkumar2@in.ibm.com>, <ernesto.martin@viasat.com>,
	<haixiao@juniper.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351748762-3455-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/31/2012 10:45 PM, Jason Wang wrote:
> Hello All:
> 
> This is an update of multiqueue support in tuntap from V3. Please consider to
> merge.
> 
> The main idea for this series is to let tun/tap device to be benefited from
> multiqueue network cards and multi-core host. We used to have a single queue for
> tuntap which could be a bottleneck in a multiqueue/core environment. So this
> series let the device could be attched with multiple sockets and expose them
> through fd to the userspace as multiqueues. The sereis were orignally designed
> to serve as backend for multiqueue virtio-net in KVM, but the design is generic
> for other application to be used.
> 
> Some quick overview of the design:
> 
> - Moving socket from tun_device to tun_file.
> - Allowing multiple sockets to be attached to a tun/tap devices.
> - Using RCU to synchronize the data path and system call.
> - Two new ioctls were added for the usespace to attach and detach socket to the
>   device.
> - API compatibility were maintained without userspace notable changes, so legacy
>   userspace that only use one queue won't need any changes.
> - A flow(rxhash) to queue table were maintained by tuntap which choose the txq
>   based on the last rxq where it comes.

I'm still trying to wrap my head around the new locking/RCU stuff but it looks like
Paul and others already looked at it.

Otherwise looks good to me.

btw In the description above you really meant allowing for attaching multiple file
descriptors not sockets.

Thanks
Max
