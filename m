From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 4/4] bridge: Fix updating FDB entries when the PVID
 is applied
Date: Tue, 10 Sep 2013 10:24:39 -0400
Message-ID: <522F2BA7.3090308@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita> <1378809571.3988.13.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab3IJOYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 10:24:45 -0400
In-Reply-To: <1378809571.3988.13.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2013 06:39 AM, Toshiaki Makita wrote:
> We currently set the value that variable vid pointing, which will be used
> in FDB later, to 0 at br_allowed_ingress() when we receive untagged or
> priority-tagged frames, even though the PVID is valid.
> This leads to FDB updates in such a wrong way that they are learned with
> VID 0.
> Update the value to that of PVID if the PVID is applied.
>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Reviewed-by: Vlad Yasevich <vyasevich@redhat.com>

-vlad

> ---
>   net/bridge/br_vlan.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 5a9c44a..53f0990 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -217,6 +217,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>   		/* PVID is set on this port.  Any untagged or priority-tagged
>   		 * ingress frame is considered to belong to this vlan.
>   		 */
> +		*vid = pvid;
>   		if (likely(err))
>   			/* Untagged Frame. */
>   			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
>
