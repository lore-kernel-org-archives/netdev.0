From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH] doc: fix wrongly referencing dev->skb_mark
Date: Mon, 10 Oct 2016 16:49:43 +0300
Message-ID: <20161010134943.GA8090@splinter>
References: <1476098139-6333-1-git-send-email-ozaki.ryota@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:52218 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752360AbcJJNtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 09:49:51 -0400
Content-Disposition: inline
In-Reply-To: <1476098139-6333-1-git-send-email-ozaki.ryota@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Oct 10, 2016 at 08:15:39PM +0900, Ryota Ozaki wrote:
> Section "Flooding L2 domain" says, to avoid duplicated flooding, if
> skb->offload_fwd_mark is matched with dev->skb_mark, the kernel will
> drop the packet. However, the relevant code in __dev_queue_xmit
> compares skb->offload_fwd_mark with dev->offload_fwd_mark, not
> dev->skb_mark. I guess the text is wrong.
> 
> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
> ---
>  Documentation/networking/switchdev.txt | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> index 31c3911..d4124a0 100644
> --- a/Documentation/networking/switchdev.txt
> +++ b/Documentation/networking/switchdev.txt
> @@ -286,8 +286,8 @@ otherwise there will be duplicate packets on the wire.
>  To avoid duplicate packets, the device/driver should mark a packet as already
>  forwarded using skb->offload_fwd_mark.  The same mark is set on the device
>  ports in the domain using dev->offload_fwd_mark.  If the skb->offload_fwd_mark
> -is non-zero and matches the forwarding egress port's dev->skb_mark, the kernel
> -will drop the skb right before transmit on the egress port, with the
> +is non-zero and matches the forwarding egress port's dev->offload_fwd_mark,
> +the kernel will drop the skb right before transmit on the egress port, with the

I think your tree isn't up to date. The flooding mechanism (and this
document) were modified in commit 6bc506b4fb06 ("bridge: switchdev: Add
forward mark support for stacked devices")
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6bc506b4fb065eac3d89ca1ce37082e174493d9e

Also, in the future, please specify to which tree (net, net-next) your
patch should go. See:
https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt
(under "How do I indicate which tree (net vs. net-next) my patch
should be in?").

Thanks!

>  understanding that the device already forwarded the packet on same egress port.
>  The driver can use switchdev_port_fwd_mark_set() to set a globally unique mark
>  for port's dev->offload_fwd_mark, based on the port's parent ID (switch ID) and
> -- 
> 2.7.4
> 
