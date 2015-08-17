From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio-net: add default_mtu configuration field
Date: Mon, 17 Aug 2015 11:07:15 +0800
Message-ID: <55D14FE3.8040307@redhat.com>
References: <1439732494-29765-1-git-send-email-victork@redhat.com>
	<1439732494-29765-3-git-send-email-victork@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com
To: Victor Kaplansky <victork@redhat.com>, virtio-dev@lists.oasis-open.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1439732494-29765-3-git-send-email-victork@redhat.com>
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



On 08/16/2015 09:42 PM, Victor Kaplansky wrote:
> Sometimes it is essential for libvirt to be able to configure MTU
> on guest's NICs to a value different from 1500.
>
> The change adds a new field to configuration area of network
> devices. It will be used to pass initial MTU from the device to
> the driver, and to pass modified MTU from driver to the device
> when a new MTU is assigned by the guest OS.
>
> In addition, in order to support backward and forward
> compatibility, we introduce a new feature bit called
> VIRTIO_NET_F_DEFAULT_MTU.
>
> Added conformance statements for a device and a driver.
>
> Signed-off-by: Victor Kaplansky <victork@redhat.com>
>
>     Signed-off-by: Victor Kaplansky <victork@redhat.com>
> ---
>  content.tex | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
>
> diff --git a/content.tex b/content.tex
> index 342183b..439d005 100644
> --- a/content.tex
> +++ b/content.tex
> @@ -3078,6 +3078,12 @@ features.
>  
>  \item[VIRTIO_NET_F_CTRL_MAC_ADDR(23)] Set MAC address through control
>      channel.
> +
> +\item[VIRTIO_NET_F_DEFAULT_MTU(24)] Default MTU is supported.  If
> +    offered by the device, device advises driver about initial MTU to
> +    be used. If negotiated, the driver uses \field{default_mtu} as
> +    an initial value and reports MTU changes to the device.
> +
>  \end{description}
>  
>  \subsubsection{Feature bit requirements}\label{sec:Device Types / Network Device / Feature bits / Feature bit requirements}
> @@ -3128,6 +3134,7 @@ struct virtio_net_config {
>          u8 mac[6];
>          le16 status;
>          le16 max_virtqueue_pairs;
> +        le16 default_mtu;

Looks like "mtu" is ok, consider we use "mac" instead of "default_mac".

>  };
>  \end{lstlisting}
>  
> @@ -3158,6 +3165,15 @@ by the driver after negotiation.
>      \field{max_virtqueue_pairs} is valid only if VIRTIO_NET_F_MQ is
>      set and can be read by the driver.
>  
> +\item [\field{default_mtu}] is a hint to the driver set by the
> +    device. It is valid during feature negotiation only if
> +    VIRTIO_NET_F_DEFAULT_MTU is offered and holds the initial value
> +    of MTU to be used by the driver. If VIRTIO_NET_F_DEFAULT_MTU is
> +    negotiated, the driver uses the \field{default_mtu} as an initial
> +    value, and also reports MTU changes to the device by writes to
> +    \field{default_mtu}.  Such reporting can be used for debugging,
> +    or it can be used for tunning MTU along the network.
> +

I vaguely remember that config is read only in some arch or transport
and that's why we introduce another vq cmd to confirm the announcement.
Probably we should do same for this?
