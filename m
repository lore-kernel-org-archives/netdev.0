From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 1/2] virtio-net: rephrase devconf fields description
Date: Mon, 17 Aug 2015 10:43:46 +0800
Message-ID: <55D14A62.2060408@redhat.com>
References: <1439732494-29765-1-git-send-email-victork@redhat.com> <1439732494-29765-2-git-send-email-victork@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Victor Kaplansky <victork@redhat.com>,
	virtio-dev@lists.oasis-open.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbbHQCnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 22:43:50 -0400
In-Reply-To: <1439732494-29765-2-git-send-email-victork@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/16/2015 09:42 PM, Victor Kaplansky wrote:
> Clarify general description of the mac, status and
> max_virtqueue_pairs fields. Specifically, the old description is
> vague about configuration layout and fields offsets when some of
> the fields are non valid.
>
> Also clarify that validity of two status bits depends on two
> different feature flags.
>
> Signed-off-by: Victor Kaplansky <victork@redhat.com>
> ---
>  content.tex | 42 +++++++++++++++++++++++++++++++-----------
>  1 file changed, 31 insertions(+), 11 deletions(-)
>
> diff --git a/content.tex b/content.tex
> index d989d98..342183b 100644
> --- a/content.tex
> +++ b/content.tex
> @@ -3115,23 +3115,14 @@ were needed.
>  \subsection{Device configuration layout}\label{sec:Device Types / Network Device / Device configuration layout}
>  \label{sec:Device Types / Block Device / Feature bits / Device configuration layout}
>  
> -Three driver-read-only configuration fields are currently defined. The \field{mac} address field
> -always exists (though is only valid if VIRTIO_NET_F_MAC is set), and
> -\field{status} only exists if VIRTIO_NET_F_STATUS is set. Two
> -read-only bits (for the driver) are currently defined for the status field:
> -VIRTIO_NET_S_LINK_UP and VIRTIO_NET_S_ANNOUNCE.
> +
> +The following configuration fields are currently defined:
>  
>  \begin{lstlisting}
>  #define VIRTIO_NET_S_LINK_UP     1
>  #define VIRTIO_NET_S_ANNOUNCE    2
>  \end{lstlisting}
>  
> -The following driver-read-only field, \field{max_virtqueue_pairs} only exists if
> -VIRTIO_NET_F_MQ is set. This field specifies the maximum number
> -of each of transmit and receive virtqueues (receiveq1\ldots receiveqN
> -and transmitq1\ldots transmitqN respectively) that can be configured once VIRTIO_NET_F_MQ
> -is negotiated.
> -
>  \begin{lstlisting}
>  struct virtio_net_config {
>          u8 mac[6];
> @@ -3140,6 +3131,35 @@ struct virtio_net_config {
>  };
>  \end{lstlisting}
>  
> +\field{mac}, \field{status}, \field{max_virtqueue_pairs} are
> +driver-read-only. \field{default_mtu} can also be written
> +by the driver after negotiation.
> +
> +\begin{description}
> +\item [\field{mac}] is MAC address assigned by the device and is valid
> +    only if VIRTIO_NET_F_MAC is offered.
> +
> +\item [\field{status}] consists of two driver-read-only status bits:
> +
> +\begin{description}
> +
> +\item VIRTIO_NET_S_LINK_UP is valid if VIRTIO_NET_F_STATUS is
> +    offered.
> +
> +\item VIRTIO_NET_S_ANNOUNCE is valid if
> +    VIRTIO_NET_F_GUEST_ANNOUNCE is offered.
> +
> +\end{description}
> +
> +\item [\field{max_virtqueue_pairs}] tells the driver the maximum
> +    number of each of virtqueues (receiveq1\ldots receiveqN and
> +    transmitq1\ldots transmitqN respectively) that can be configured
> +    on the device once VIRTIO_NET_F_MQ is negotiated.
> +    \field{max_virtqueue_pairs} is valid only if VIRTIO_NET_F_MQ is
> +    set and can be read by the driver.
> +

Hi:

I don't get the point that adding "can be read by the driver". Looks
like it's hard for hypervisor to detect this?

Thanks
