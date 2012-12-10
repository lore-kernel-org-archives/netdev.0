From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCHv6] virtio-spec: virtio network device multiqueue support
Date: Mon, 10 Dec 2012 13:54:36 +0800
Message-ID: <25100637.sFX29GsU00@jason-thinkpad-t430s>
References: <20121207141856.GA17901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121207141856.GA17901@redhat.com>
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

On Friday, December 07, 2012 04:18:56 PM Michael S. Tsirkin wrote:
> Add multiqueue support to virtio network device.
> Add a new feature flag VIRTIO_NET_F_MQ for this feature, a new
> configuration field max_virtqueue_pairs to detect supported number of
> virtqueues as well as a new command VIRTIO_NET_CTRL_MQ to program
> packet steering for unidirectional protocols.
> 
> ---
> 
> Changes in v6:
> - rename RFS -> multiqueue to avoid confusion with RFS in linux
>   mention automatic receive steering as Rusty suggested
> 
> Changes in v5:
> - Address Rusty's comments.
>   Changes are only in the text, not the ideas.
> - Some minor formatting changes.
> 
> Changes in v4:
> - address Jason's comments
> - have configuration specify the number of VQ pairs and not pairs - 1
> 
> Changes in v3:
> - rename multiqueue -> rfs this is what we support
> - Be more explicit about what driver should do.
> - Simplify layout making VQs functionality depend on feature.
> - Remove unused commands, only leave in programming # of queues
> 
> Changes in v2:
> Address Jason's comments on v2:
> - Changed STEERING_HOST to STEERING_RX_FOLLOWS_TX:
>    this is both clearer and easier to support.
>    It does not look like we need a separate steering command
>    since host can just watch tx packets as they go.
> - Moved RX and TX steering sections near each other.
> - Add motivation for other changes in v2
> 
> Changes in v1 (from Jason's rfc):
> - reserved vq 3: this makes all rx vqs even and tx vqs odd, which
>    looks nicer to me.
> - documented packet steering, added a generalized steering programming
>    command. Current modes are single queue and host driven multiqueue,
>    but I envision support for guest driven multiqueue in the future.
> - make default vqs unused when in mq mode - this wastes some memory
>    but makes it more efficient to switch between modes as
>    we can avoid this causing packet reordering.
> 
> Rusty, could you please take a look and comment soon?
> If this looks OK to everyone, we can proceed with finalizing the
> implementation. Would be nice to try and put it in 3.8.
> 
> diff --git a/virtio-spec.lyx b/virtio-spec.lyx
> index 83f2771..c5b32c4 100644
> --- a/virtio-spec.lyx
> +++ b/virtio-spec.lyx
> @@ -59,6 +59,7 @@
>  \author -608949062 "Rusty Russell,,,"
>  \author -385801441 "Cornelia Huck" cornelia.huck@de.ibm.com
>  \author 1531152142 "Paolo Bonzini,,,"
> +\author 1986246365 "Michael S. Tsirkin"
>  \end_header
[...]
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594263
> +
> +#define VIRTIO_NET_CTRL_MQ    1

Should be 4 here.
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594273
> +
> + #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET        0
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594273
> +
> + #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN        1
> +\end_layout
> +
[...]
