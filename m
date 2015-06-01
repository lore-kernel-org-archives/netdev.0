From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 3/8] macvtap: introduce macvtap_is_little_endian()
	helper
Date: Mon, 1 Jun 2015 12:30:16 +0200
Message-ID: <20150601122950-mutt-send-email-mst@redhat.com>
References: <20150424122211.19156.97626.stgit@bahia.local>
	<20150424122446.19156.93123.stgit@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Huth <thuth@redhat.com>, kvm@vger.kernel.org,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20150424122446.19156.93123.stgit@bahia.local>
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

On Fri, Apr 24, 2015 at 02:24:48PM +0200, Greg Kurz wrote:
> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>

Dave, could you pls ack merging this through the virtio tree?

> ---
>  drivers/net/macvtap.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 27ecc5c..a2f2958 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -49,14 +49,19 @@ struct macvtap_queue {
>  
>  #define MACVTAP_VNET_LE 0x80000000
>  
> +static inline bool macvtap_is_little_endian(struct macvtap_queue *q)
> +{
> +	return q->flags & MACVTAP_VNET_LE;
> +}
> +
>  static inline u16 macvtap16_to_cpu(struct macvtap_queue *q, __virtio16 val)
>  {
> -	return __virtio16_to_cpu(q->flags & MACVTAP_VNET_LE, val);
> +	return __virtio16_to_cpu(macvtap_is_little_endian(q), val);
>  }
>  
>  static inline __virtio16 cpu_to_macvtap16(struct macvtap_queue *q, u16 val)
>  {
> -	return __cpu_to_virtio16(q->flags & MACVTAP_VNET_LE, val);
> +	return __cpu_to_virtio16(macvtap_is_little_endian(q), val);
>  }
>  
>  static struct proto macvtap_proto = {
> 
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
