From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] rfkill: Add handling when rfkill's type is
 RFKILL_TYPE_ALL.
Date: Tue, 22 May 2012 20:46:39 +0200
Message-ID: <1337712399.4470.5.camel@jlt3.sipsolutions.net>
References: <1337589439-14605-1-git-send-email-alex.hung@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alex Hung <alex.hung-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1337589439-14605-1-git-send-email-alex.hung-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-21 at 16:37 +0800, Alex Hung wrote:
> This rfkill type is supposed to be able to toggles the status of all wireless
> devices; however, no wireless devices will register itself with type 
> RFKILL_TYPE_ALL and thus it was previously ignored in __rfkill_switch_all.
> 
> Signed-off-by: Alex Hung <alex.hung-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  net/rfkill/core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index 5be1957..84dd71a 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -324,7 +324,7 @@ static void __rfkill_switch_all(const enum rfkill_type type, bool blocked)
>  
>  	rfkill_global_states[type].cur = blocked;
>  	list_for_each_entry(rfkill, &rfkill_list, node) {
> -		if (rfkill->type != type)
> +		if (rfkill->type != type && type != RFKILL_TYPE_ALL)
>  			continue;

Sorry, I accidentally replied to this in private and then Alex replied
but it all got lost.

He said he was going to change the eeepc use KEY_RFKILL instead of
KEY_WLAN to switch all types...

So I guess what this change really does is make __rfkill_switch_all() be
able to not only switch all devices of a given type, but also be able to
switch all devices of all types.

Alex, can you please rewrite the commit log to make that clearer?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
