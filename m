From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net v2] flow_dissector: Check skb for VLAN only if skb specified.
Date: Tue, 18 Oct 2016 14:44:32 +0200
Message-ID: <87lgxlltcf.fsf@redhat.com>
References: <1476736212-21238-1-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:34028 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759616AbcJRMoe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 08:44:34 -0400
Received: by mail-qt0-f169.google.com with SMTP id q7so154235682qtq.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 05:44:34 -0700 (PDT)
In-reply-to: <1476736212-21238-1-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 08:30 PM GMT, Eric Garver wrote:
> Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.
>
> Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
> Signed-off-by: Eric Garver <e@erig.me>
> ---
>  net/core/flow_dissector.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 1a7b80f73376..44e6ba9d3a6b 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -247,12 +247,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>  	case htons(ETH_P_8021Q): {
>  		const struct vlan_hdr *vlan;
>  
> -		if (skb_vlan_tag_present(skb))
> +		if (skb && skb_vlan_tag_present(skb))
>  			proto = skb->protocol;
>  

I was a bit confused that we check skb for VLAN tag again later in the
same block but this time without a NULL check. However, this only
happens when we get called from skb_flow_dissect() or
skb_flow_dissect_flow_keys() variants, which take an skb and pass it to
us.

Feel free to add:

Reviewed-by: Jakub Sitnicki <jkbs@redhat.com>
