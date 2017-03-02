From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-v4-RESEND 1/4] vsock: track pkt owner vsock
Date: Thu, 02 Mar 2017 13:13:03 -0800 (PST)
Message-ID: <20170302.131303.703202861280343181.davem@davemloft.net>
References: <1488340587-32416-1-git-send-email-bergwolf@gmail.com>
	<1488340587-32416-2-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, stefanha@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: bergwolf@gmail.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1488340587-32416-2-git-send-email-bergwolf@gmail.com>
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

From: Peng Tao <bergwolf@gmail.com>
Date: Wed,  1 Mar 2017 11:56:24 +0800

> So that we can cancel a queued pkt later if necessary.
> 
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  include/linux/virtio_vsock.h            | 2 ++
>  net/vmw_vsock/virtio_transport_common.c | 7 +++++++
>  2 files changed, 9 insertions(+)
> 
> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
> index 9638bfe..193ad3a 100644
> --- a/include/linux/virtio_vsock.h
> +++ b/include/linux/virtio_vsock.h
> @@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
>  	struct virtio_vsock_hdr	hdr;
>  	struct work_struct work;
>  	struct list_head list;
> +	void *cancel_token; /* only used for cancellation */

The type here is fixed, you only store vhost_sock object pointers
here, so don't use "void *" please.
