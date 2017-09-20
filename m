From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211: avoid allocating TXQs that won't be used
Date: Wed, 20 Sep 2017 19:51:44 +0200
Message-ID: <1505929904.3026.17.camel@sipsolutions.net>
References: <3592b0b1-0455-ca9a-9ca7-702d7cf421ff@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3592b0b1-0455-ca9a-9ca7-702d7cf421ff-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-20 at 17:08 +0100, Colin Ian King wrote:
> Johannes,
> 
> Static analysis with CoverityScan on linux-next today detected a null
> pointer dereference issue on commit:
> 
> From 0fc4b3403d215ecd3c05505ec1f0028a227ed319 Mon Sep 17 00:00:00
> 2001
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date: Thu, 22 Jun 2017 12:20:29 +0200
> Subject: [PATCH] mac80211: avoid allocating TXQs that won't be used
> 
> Issue: sdata is null when the sdata is dereferenced by:
> 
>                    sdata->vif.type != NL80211_IFTYPE_AP_VLAN &&
>                    sdata->vif.type != NL80211_IFTYPE_MONITOR)
> 
> note that sdata is assigned a non-null much later with the statement
> sdata = netdev_priv(ndev).

Yeah, umm, that should be checking just 'type'. Thanks, will fix.

johannes
