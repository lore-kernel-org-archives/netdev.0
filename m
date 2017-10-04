From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/5] VSOCK: add sock_diag interface
Date: Wed, 04 Oct 2017 15:58:57 -0700 (PDT)
Message-ID: <20171004.155857.1016136695967325282.davem@davemloft.net>
References: <20171004163716.3964-1-stefanha@redhat.com>
        <20171004163716.3964-5-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdJDW66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 18:58:58 -0400
In-Reply-To: <20171004163716.3964-5-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Wed,  4 Oct 2017 12:37:15 -0400

> This patch adds the sock_diag interface for querying sockets from
> userspace.  Tools like ss(8) and netstat(8) can use this interface to
> list open sockets.
> 
> The userspace ABI is defined in <linux/vm_sockets_diag.h> and includes
> netlink request and response structs.  The request can query sockets
> based on their sk_state (e.g. listening sockets only) and the response
> contains socket information fields including the local/remote addresses,
> inode number, etc.
> 
> This patch does not dump VMCI pending sockets because I have only tested
> the virtio transport, which does not use pending sockets.  Support can
> be added later by extending vsock_diag_dump() if needed by VMCI users.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>

Please post new feature patches against net-next.

> diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
> index 09fc2eb29dc8..e5dbf153aff0 100644
> --- a/net/vmw_vsock/Makefile
> +++ b/net/vmw_vsock/Makefile
> @@ -1,10 +1,13 @@
>  obj-$(CONFIG_VSOCKETS) += vsock.o
> +obj-$(CONFIG_VSOCKETS_DIAG) += vsock_diag.o
>  obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
>  obj-$(CONFIG_VIRTIO_VSOCKETS) += vmw_vsock_virtio_transport.o
>  obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += vmw_vsock_virtio_transport_common.o
>  

This hunk fails to apply to the net-next tree, the context looks
different.

Thanks.
