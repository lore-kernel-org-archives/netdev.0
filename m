From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 2/8] tun: add tun_is_little_endian() helper
Date: Mon, 1 Jun 2015 12:29:43 +0200
Message-ID: <20150601122910-mutt-send-email-mst@redhat.com>
References: <20150424122211.19156.97626.stgit@bahia.local>
	<20150424122435.19156.18985.stgit@bahia.local>
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
In-Reply-To: <20150424122435.19156.18985.stgit@bahia.local>
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

On Fri, Apr 24, 2015 at 02:24:38PM +0200, Greg Kurz wrote:
> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>

Dave, could you please ack merging this through
the virtio tree?

> ---
>  drivers/net/tun.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 857dca4..3c3d6c0 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -206,14 +206,19 @@ struct tun_struct {
>  	u32 flow_count;
>  };
>  
> +static inline bool tun_is_little_endian(struct tun_struct *tun)
> +{
> +	return tun->flags & TUN_VNET_LE;
> +}
> +
>  static inline u16 tun16_to_cpu(struct tun_struct *tun, __virtio16 val)
>  {
> -	return __virtio16_to_cpu(tun->flags & TUN_VNET_LE, val);
> +	return __virtio16_to_cpu(tun_is_little_endian(tun), val);
>  }
>  
>  static inline __virtio16 cpu_to_tun16(struct tun_struct *tun, u16 val)
>  {
> -	return __cpu_to_virtio16(tun->flags & TUN_VNET_LE, val);
> +	return __cpu_to_virtio16(tun_is_little_endian(tun), val);
>  }
>  
>  static inline u32 tun_hashfn(u32 rxhash)
> 
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
