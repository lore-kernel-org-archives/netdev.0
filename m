From: Sage Weil <sage@newdream.net>
Subject: Re: [PATCH] ceph: fix possible NULL pointer dereference
Date: Sat, 26 Mar 2011 13:48:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.1103261347580.17758@cobra.newdream.net>
References: <1301164174-8597-1-git-send-email-mk@lab.zgora.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <mk@lab.zgora.pl>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1301164174-8597-1-git-send-email-mk@lab.zgora.pl>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied, thanks!

sage


On Sat, 26 Mar 2011, Mariusz Kozlowski wrote:

> This patch fixes 'event_work' dereference before it is checked for NULL.
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
> ---
>  net/ceph/osd_client.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
> index 02212ed..b6776cb 100644
> --- a/net/ceph/osd_client.c
> +++ b/net/ceph/osd_client.c
> @@ -1602,11 +1602,11 @@ void handle_watch_notify(struct ceph_osd_client *osdc, struct ceph_msg *msg)
>  	     cookie, ver, event);
>  	if (event) {
>  		event_work = kmalloc(sizeof(*event_work), GFP_NOIO);
> -		INIT_WORK(&event_work->work, do_event_work);
>  		if (!event_work) {
>  			dout("ERROR: could not allocate event_work\n");
>  			goto done_err;
>  		}
> +		INIT_WORK(&event_work->work, do_event_work);
>  		event_work->event = event;
>  		event_work->ver = ver;
>  		event_work->notify_id = notify_id;
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
