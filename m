From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] iwlwifi: small compile warnings without
	CONFIG_IWLWIFI_DEBUG
Date: Thu, 17 Jul 2008 15:26:27 +0400
Message-ID: <1216293987.7034.5.camel@iris.sw.ru>
References: <1216286365-11703-1-git-send-email-den@openvz.org>
	 <1216286365-11703-2-git-send-email-den@openvz.org>
	 <1ba2fa240807170408w13837d67hcfd1be50fdb07738@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240807170408w13837d67hcfd1be50fdb07738-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-07-17 at 14:08 +0300, Tomas Winkler wrote:
> On Thu, Jul 17, 2008 at 12:19 PM, Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > CC [M]  drivers/net/wireless/iwlwifi/iwl-4965-rs.o
> > drivers/net/wireless/iwlwifi/iwl-4965-rs.c: In function 'rs_clear':
> > drivers/net/wireless/iwlwifi/iwl-4965-rs.c:2405: warning: unused variable 'priv'
> > CC [M]  drivers/net/wireless/iwlwifi/iwl-scan.o
> > drivers/net/wireless/iwlwifi/iwl-scan.c: In function 'iwl_rx_scan_complete_notif':
> > drivers/net/wireless/iwlwifi/iwl-scan.c:274: warning: unused variable 'scan_notif'
> >
> > Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > ---
> >  drivers/net/wireless/iwlwifi/iwl-4965-rs.c |    2 ++
> >  drivers/net/wireless/iwlwifi/iwl-scan.c    |    2 ++
> >  2 files changed, 4 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
> > index 3ccb84a..7549834 100644
> > --- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
> > +++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
> > @@ -2402,7 +2402,9 @@ static void rs_free(void *priv_rate)
> >
> >  static void rs_clear(void *priv_rate)
> >  {
> > +#ifdef CONFIG_IWLWIFI_DEBUG
> >        struct iwl_priv *priv = (struct iwl_priv *) priv_rate;
> > +#endif
> >
> >        IWL_DEBUG_RATE("enter\n");
> 
> move #endif after debug print

Are you proposing to do this?
static void rs_clear(void *priv_rate)
{
#ifdef CONFIG_IWLWIFI_DEBUG
        struct iwl_priv *priv = (struct iwl_priv *) priv_rate;

        IWL_DEBUG_RATE("enter\n");

        /* TODO - add rate scale state reset */

        IWL_DEBUG_RATE("leave\n");
#endif
}
this seems wrong to me, as there are pending actions inside.

It looks like you do not have warning as previously these calls are
static inlines. So, my patch seems better for the place.

If you agree with this, I'll resend the patch with
iwl_rx_scan_results_notif modified.

Regards,
	Den

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
