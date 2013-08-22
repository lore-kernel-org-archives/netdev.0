From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] Revert "genetlink: fix family dump race"
Date: Wed, 21 Aug 2013 21:29:05 -0700
Message-ID: <CALnjE+qZZ0Ln5Oh_r5B88LmRzED3WAd_WNi8TF+be7zNavkuYg@mail.gmail.com>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	<1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:39225 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752468Ab3HVE3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 00:29:06 -0400
Received: by mail-qa0-f43.google.com with SMTP id cl20so87526qab.2
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 21:29:05 -0700 (PDT)
In-Reply-To: <1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 21, 2013 at 7:08 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
> From: Johannes Berg <johannes.berg@intel.com>
>
> This reverts commit 58ad436fcf49810aa006016107f494c9ac9013db.
>
> It turns out that the change introduced a potential deadlock
> by causing a locking dependency with netlink's cb_mutex. I
> can't seem to find a way to resolve this without doing major
> changes to the locking, so revert this.
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>


Acked-by: Pravin B Shelar <pshelar@nicira.com>

>
> ---
>  net/netlink/genetlink.c | 7 -------
>  1 file changed, 7 deletions(-)
>
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index f85f8a2..512718a 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -789,10 +789,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
>         struct net *net = sock_net(skb->sk);
>         int chains_to_skip = cb->args[0];
>         int fams_to_skip = cb->args[1];
> -       bool need_locking = chains_to_skip || fams_to_skip;
> -
> -       if (need_locking)
> -               genl_lock();
>
>         for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
>                 n = 0;
> @@ -814,9 +810,6 @@ errout:
>         cb->args[0] = i;
>         cb->args[1] = n;
>
> -       if (need_locking)
> -               genl_unlock();
> -
>         return skb->len;
>  }
>
> --
> 1.8.4.rc2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
