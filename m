From: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/11 net-2.6.26] [DCCP]: Replace socket with sock for
	reset sending.
Date: Fri, 28 Mar 2008 11:39:59 -0300
Message-ID: <20080328143959.GT14945@ghostprotocols.net>
References: <1206695071.3271.8.camel@iris.sw.ru>
	<1206695338-5947-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1206695338-5947-2-git-send-email-den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Fri, Mar 28, 2008 at 12:08:49PM +0300, Denis V. Lunev escreveu:
> Replace dccp_v(4|6)_ctl_socket with sock to unify a code with TCP/ICMP.
> 
> Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  net/dccp/ipv4.c |   16 +++++++++-------
>  net/dccp/ipv6.c |   10 ++++++----
>  2 files changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 4ca8b0c..79a9a4a 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -36,7 +36,7 @@
>   * the Out-of-the-blue (OOTB) packets. A control sock will be created
>   * for this socket at the initialization time.
>   */
> -static struct socket *dccp_v4_ctl_socket;
> +static struct sock *dccp_v4_ctl_sk;
>  
>  int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  {
> @@ -514,11 +514,11 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
>  	if (rxskb->rtable->rt_type != RTN_LOCAL)
>  		return;
>  
> -	dst = dccp_v4_route_skb(dccp_v4_ctl_socket->sk, rxskb);
> +	dst = dccp_v4_route_skb(dccp_v4_ctl_sk, rxskb);
>  	if (dst == NULL)
>  		return;
>  
> -	skb = dccp_ctl_make_reset(dccp_v4_ctl_socket, rxskb);
> +	skb = dccp_ctl_make_reset(dccp_v4_ctl_sk->sk_socket, rxskb);

Why not make dccp_ctl_make_reset receive a struct sock too? It only uses
ctl->sk anyway. But I guess that can be on a follow-up patch, could you
that?

Thanks,

- Arnaldo
