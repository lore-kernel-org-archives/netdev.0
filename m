From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] netns bridge: cleanup bridges during netns stop
Date: Sat, 6 Sep 2008 18:38:21 -0700
Message-ID: <20080906183821.1da26204@extreme>
References: <20080906064408.GB7810@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080906064408.GB7810-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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

On Sat, 6 Sep 2008 10:44:08 +0400
Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 
>  net/bridge/br.c         |   22 ++++++++++++++++------
>  net/bridge/br_if.c      |    4 ++--
>  net/bridge/br_private.h |    2 +-
>  3 files changed, 19 insertions(+), 9 deletions(-)
> 
> --- a/net/bridge/br.c
> +++ b/net/bridge/br.c
> @@ -28,6 +28,10 @@ static const struct stp_proto br_stp_proto = {
>  	.rcv	= br_stp_rcv,
>  };
>  
> +static struct pernet_operations br_net_ops = {
> +	.exit	= br_net_exit,
> +};
> +

Acked-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

overall, this is fine, but you might want to think about making
pernet_operations const if possible in future.
