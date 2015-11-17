From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost: relax log address alignment
Date: Tue, 17 Nov 2015 13:40:55 +0800
Message-ID: <564ABDE7.4040700@redhat.com>
References: <1447685995-16282-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1447685995-16282-1-git-send-email-mst@redhat.com>
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



On 11/16/2015 11:00 PM, Michael S. Tsirkin wrote:
> commit 5d9a07b0de512b77bf28d2401e5fe3351f00a240 ("vhost: relax used
> address alignment") fixed the alignment for the used virtual address,
> but not for the physical address used for logging.
>
> That's a mistake: alignment should clearly be the same for virtual and
> physical addresses,
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/vhost.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index eec2f11..080422f 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -819,7 +819,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  		BUILD_BUG_ON(__alignof__ *vq->used > VRING_USED_ALIGN_SIZE);
>  		if ((a.avail_user_addr & (VRING_AVAIL_ALIGN_SIZE - 1)) ||
>  		    (a.used_user_addr & (VRING_USED_ALIGN_SIZE - 1)) ||
> -		    (a.log_guest_addr & (sizeof(u64) - 1))) {
> +		    (a.log_guest_addr & (VRING_USED_ALIGN_SIZE - 1))) {
>  			r = -EINVAL;
>  			break;
>  		}

Acked-by: Jason Wang <jasowang@redhat.com>
