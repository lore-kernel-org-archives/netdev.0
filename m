From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: move is_le setup to the backend
Date: Mon, 02 Nov 2015 15:09:22 -0500 (EST)
Message-ID: <20151102.150922.1956383631313633658.davem@davemloft.net>
References: <20151030114235.28847.63465.stgit@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: gkurz@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151030114235.28847.63465.stgit@bahia.huguette.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Date: Fri, 30 Oct 2015 12:42:35 +0100

> The vq->is_le field is used to fix endianness when accessing the vring via
> the cpu_to_vhost16() and vhost16_to_cpu() helpers in the following cases:
> 
> 1) host is big endian and device is modern virtio
> 
> 2) host has cross-endian support and device is legacy virtio with a different
>    endianness than the host
> 
> Both cases rely on the VHOST_SET_FEATURES ioctl, but 2) also needs the
> VHOST_SET_VRING_ENDIAN ioctl to be called by userspace. Since vq->is_le
> is only needed when the backend is active, it was decided to set it at
> backend start.
> 
> This is currently done in vhost_init_used()->vhost_init_is_le() but it
> obfuscates the core vhost code. This patch moves the is_le setup to a
> dedicated function that is called from the backend code.
> 
> Note vhost_net is the only backend that can pass vq->private_data == NULL to
> vhost_init_used(), hence the "if (sock)" branch.
> 
> No behaviour change.
> 
> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>

Michael, I'm assuming that you will be the one taking this.
