From: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/11 net-2.6.26] [ICMP]: Simplify ICMP control socket
	creation.
Date: Fri, 28 Mar 2008 11:47:26 -0300
Message-ID: <20080328144726.GV14945@ghostprotocols.net>
References: <1206695071.3271.8.camel@iris.sw.ru>
	<1206695338-5947-7-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1206695338-5947-7-git-send-email-den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

Em Fri, Mar 28, 2008 at 12:08:54PM +0300, Denis V. Lunev escreveu:
> Replace sock_create_kern with inet_csk_ctl_sock_create.
> 
> Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  net/ipv4/icmp.c |   23 +++++------------------
>  1 files changed, 5 insertions(+), 18 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 803bc9f..b00bc20 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -1152,33 +1152,20 @@ int __net_init icmp_sk_init(struct net *net)
>  
>  	for_each_possible_cpu(i) {
>  		struct sock *sk;
> -		struct socket *sock;
> -		struct inet_sock *inet;
>  
> -		err = sock_create_kern(PF_INET, SOCK_RAW, IPPROTO_ICMP, &sock);
> +		err = inet_csk_ctl_sock_create(&sk,
> +					       PF_INET, SOCK_RAW, IPPROTO_ICMP);

And ICMP surely is not a inet_connection_sock, so please rename it as
suggested in another message.

- Arnaldo
