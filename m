From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v3 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Mon, 22 Aug 2016 12:07:16 +0200
Message-ID: <20160822100716.ixxxppc7x4nce5yx@alphalink.fr>
References: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulus@samba.org, davem@davemloft.net,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49479 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752805AbcHVKH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:07:26 -0400
Content-Disposition: inline
In-Reply-To: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 20, 2016 at 11:52:27PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
> 0x03, and 2 separately.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v3: Modify the subject;
>  v2: Only replace the literal number with macros according to Guillaume's advice
>  v1: Inital patch
> 
>  net/l2tp/l2tp_ppp.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
> index d9560aa..65e2fd6 100644
> --- a/net/l2tp/l2tp_ppp.c
> +++ b/net/l2tp/l2tp_ppp.c
> @@ -177,7 +177,7 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
>  	if (!pskb_may_pull(skb, 2))
>  		return 1;
>  
> -	if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
> +	if ((skb->data[0] == PPP_ALLSTATIONS) && (skb->data[1] == PPP_UI))
>  		skb_pull(skb, 2);
>  
>  	return 0;
> @@ -282,7 +282,7 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
>  static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
>  			    size_t total_len)
>  {
> -	static const unsigned char ppph[2] = { 0xff, 0x03 };
> +	static const unsigned char ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
> 
Minor nit: I'd prefer to keep the space after '{' and before '}'.
I didn't want to bother you with this, but since it seems you'll have
to repost...

>  	struct sock *sk = sock->sk;
>  	struct sk_buff *skb;
>  	int error;
> @@ -369,7 +369,7 @@ error:
>   */
>  static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>  {
> -	static const u8 ppph[2] = { 0xff, 0x03 };
> +	static const u8 ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
> 
Same here.

BTW, I thought you also wanted to remove the static ppph variable
from pppol2tp_xmit() / pppol2tp_sendmsg(), to directly assign
skb->data[0/1] with PPP_ALLSTATIONS/PPP_UI.
