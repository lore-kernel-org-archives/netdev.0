From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net 4/4] bridge: Fix updating FDB entries when the
 PVID is applied
Date: Wed, 16 Oct 2013 08:57:15 -0700
Message-ID: <20131016085715.3442e8c3@nehalam.linuxnetplumber.net>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1381910836-718-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41913 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150Ab3JPP5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:57:19 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so1130468pdi.19
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:57:18 -0700 (PDT)
In-Reply-To: <1381910836-718-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Oct 2013 17:07:16 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> We currently set the value that variable vid is pointing, which will be
> used in FDB later, to 0 at br_allowed_ingress() when we receive untagged
> or priority-tagged frames, even though the PVID is valid.
> This leads to FDB updates in such a wrong way that they are learned with
> VID 0.
> Update the value to that of PVID if the PVID is applied.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_vlan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 5a9c44a..53f0990 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -217,6 +217,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>  		/* PVID is set on this port.  Any untagged or priority-tagged
>  		 * ingress frame is considered to belong to this vlan.
>  		 */
> +		*vid = pvid;
>  		if (likely(err))
>  			/* Untagged Frame. */
>  			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);


Ok, but side-effects seem like an indication of poor code logic
flow design. Not your fault but part of the the per-vlan filtering code.
