From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH for-3.7] vhost: fix mergeable bufs on BE hosts
Date: Sun, 21 Oct 2012 14:49:01 +0200
Message-ID: <20121021124901.GA5315@redhat.com>
References: <20121015175534.GA19489@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Alexander Graf <agraf@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20121015175534.GA19489@redhat.com>
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

On Mon, Oct 15, 2012 at 07:55:34PM +0200, Michael S. Tsirkin wrote:
> We copy head count to a 16 bit field,
> this works by chance on LE but on BE
> guest gets 0. Fix it up.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Tested-by: Alexander Graf <agraf@suse.de>
> Cc: stable@kernel.org

Ping. Dave, could you apply this to -net please?

> ---
>  drivers/vhost/net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 9ab6d47..2bb463c 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -448,7 +448,8 @@ static void handle_rx(struct vhost_net *net)
>  		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
>  	};
>  	size_t total_len = 0;
> -	int err, headcount, mergeable;
> +	int err, mergeable;
> +	s16 headcount;
>  	size_t vhost_hlen, sock_hlen;
>  	size_t vhost_len, sock_len;
>  	/* TODO: check that we are running from vhost_worker? */
> -- 
> MST
