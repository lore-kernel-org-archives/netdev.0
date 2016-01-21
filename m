From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/2] vhost: helpers to enable/disable vring endianness
Date: Thu, 21 Jan 2016 10:55:39 +0100
Message-ID: <20160121105539.63093cb6.cornelia.huck@de.ibm.com>
References: <20160113170934.23705.62626.stgit@bahia.huguette.org>
	<20160113170941.23705.93915.stgit@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160113170941.23705.93915.stgit@bahia.huguette.org>
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

On Wed, 13 Jan 2016 18:09:41 +0100
Greg Kurz <gkurz@linux.vnet.ibm.com> wrote:

> The default use case for vhost is when the host and the vring have the
> same endianness (default native endianness). But there are cases where
> they differ and vhost should byteswap when accessing the vring:
> - the host is big endian and the vring comes from a virtio 1.0 device
>   which is always little endian
> - the architecture is bi-endian and the vring comes from a legacy virtio
>   device with a different endianness than the endianness of the host (aka
>   legacy cross-endian)
> 
> These cases are handled by the vq->is_le and the optional vq->user_be,
> with the following logic:
> - if none of the fields is enabled, vhost access the vring without byteswap
> - if the vring is virtio 1.0 and the host is big endian, vq->is_le is
>   enabled to enforce little endian access to the vring
> - if the vring is legacy cross-endian, userspace enables vq->user_be
>   to inform vhost about the vring endianness. This endianness is then
>   enforced for vring accesses through vq->is_le again
> 
> The logic is unclear in the current code.
> 
> This patch introduces helpers with explicit enable and disable semantics,
> for better clarity.
> 
> No behaviour change.
> 
> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> ---
>  drivers/vhost/vhost.c |   28 +++++++++++++++++++---------
>  1 file changed, 19 insertions(+), 9 deletions(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
