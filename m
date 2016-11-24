From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 2/3] vringh: kill off ACCESS_ONCE()
Date: Thu, 24 Nov 2016 12:10:01 +0100
Message-ID: <b56245b5-c151-5cd0-8765-b57bee56a388@de.ibm.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<1479983114-17190-3-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dave@stgolabs.net, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, dbueso@suse.de,
	virtualization@lists.linux-foundation.org,
	paulmck@linux.vnet.ibm.com, dvyukov@google.com
To: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1479983114-17190-3-git-send-email-mark.rutland@arm.com>
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

On 11/24/2016 11:25 AM, Mark Rutland wrote:
> Despite living under drivers/ vringh.c is also used as part of the userspace
> virtio tools. Before we can kill off the ACCESS_ONCE()definition in the tools,
> we must convert vringh.c to use {READ,WRITE}_ONCE().
> 
> This patch does so, along with the required include of <linux/compiler.h> for
> the relevant definitions. The userspace tools provide their own definitions in
> their own <linux/compiler.h>.
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: kvm@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org
> ---
>  drivers/vhost/vringh.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
> index 3bb02c6..bb8971f 100644
> --- a/drivers/vhost/vringh.c
> +++ b/drivers/vhost/vringh.c
> @@ -3,6 +3,7 @@
>   *
>   * Since these may be in userspace, we use (inline) accessors.
>   */
> +#include <linux/compiler.h>
>  #include <linux/module.h>
>  #include <linux/vringh.h>
>  #include <linux/virtio_ring.h>
> @@ -820,13 +821,13 @@ EXPORT_SYMBOL(vringh_need_notify_user);
>  static inline int getu16_kern(const struct vringh *vrh,
>  			      u16 *val, const __virtio16 *p)
>  {
> -	*val = vringh16_to_cpu(vrh, ACCESS_ONCE(*p));
> +	*val = vringh16_to_cpu(vrh, READ_ONCE(*p));
>  	return 0;
>  }
> 
>  static inline int putu16_kern(const struct vringh *vrh, __virtio16 *p, u16 val)
>  {
> -	ACCESS_ONCE(*p) = cpu_to_vringh16(vrh, val);
> +	WRITE_ONCE(*p, cpu_to_vringh16(vrh, val));
>  	return 0;
>  }
> 

Makes sense

Reviewed-by: Christian Borntraeger <borntraeger@de.ibm.com>
