From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 3/3] mac80211: mesh: Add support for HW RC implementation
Date: Tue, 21 Jun 2016 11:18:19 +0200
Message-ID: <1466500699.3170.7.camel@sipsolutions.net>
References: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
 <1466427622-5953-2-git-send-email-maxim.altshul@ti.com>
 <1466427622-5953-3-git-send-email-maxim.altshul@ti.com>
	 <1466427622-5953-4-git-send-email-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, yanivma-l0cyMroinI0@public.gmane.org, guym-l0cyMroinI0@public.gmane.org, arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466427622-5953-4-git-send-email-maxim.altshul-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -	if (sta->mesh->fail_avg >=3D 100)
> -		return MAX_METRIC;
> +	/* try to get rate based on HW RC algorithm */
> +	rate =3D drv_get_expected_throughput(local, &sta->sta);

This doesn't look correct, since you should use the rate control op if
available, to get data from rate control algorithms.

You should call=C2=A0sta_set_sinfo(), but that's far too much, so more
likely you should factor out the last few lines of that into a new
function and call that new function in both places.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
