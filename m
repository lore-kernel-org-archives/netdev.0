From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] mac80211_hwsim: No parent is better than an
 illegimate one.
Date: Mon, 12 Jul 2010 08:46:40 +0200
Message-ID: <1278917200.3667.1.camel@jlt3.sipsolutions.net>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	 <20100621150826.762ac9f2.akpm@linux-foundation.org>
	 <m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	 <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	 <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	 <m1630q7x5v.fsf_-_@fess.ebiederm.org> <m1zky26iaw.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	"Greg KH <gregkh@suse.de> netdev" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:55370 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab0GLGs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 02:48:26 -0400
In-Reply-To: <m1zky26iaw.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-08 at 09:37 -0700, Eric W. Biederman wrote:
> Don't call SET_IEEE80211_DEV.  This weakens the connections between
> the phy files in sysfs slightly but otherwise it makes the driver work
> in the face of tagged sysfs support.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
> 
> Johannes does this change look usable?

It'll probably work, but anything in userspace relying on it will fail,
and you'll have some unused virtual devices in sysfs? Not too keen on
it, but if we really can't fix it ....

johannes

>  drivers/net/wireless/mac80211_hwsim.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
> index 6f8cb3e..b387222 100644
> --- a/drivers/net/wireless/mac80211_hwsim.c
> +++ b/drivers/net/wireless/mac80211_hwsim.c
> @@ -1282,7 +1282,6 @@ static int __init init_mac80211_hwsim(void)
>  		}
>  		data->dev->driver = &mac80211_hwsim_driver;
>  
> -		SET_IEEE80211_DEV(hw, data->dev);
>  		addr[3] = i >> 8;
>  		addr[4] = i;
>  		memcpy(data->addresses[0].addr, addr, ETH_ALEN);


