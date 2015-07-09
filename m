From: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
Subject: Re: [PATCH] mwifiex: drop condition with no effect
Date: Thu, 9 Jul 2015 07:57:47 +0200
Message-ID: <20150709055747.GA22159@opentech.at>
References: <1436364902-28943-1-git-send-email-hofrat@osadl.org> <CAJwzM1kvWfP1VB4wUoT74F-Ons1R3cpoBEAdfm37sh1p5vhh+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Avinash Patil <avinashapatil-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAJwzM1kvWfP1VB4wUoT74F-Ons1R3cpoBEAdfm37sh1p5vhh+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 08 Jul 2015, Avinash Patil wrote:

> Hi Nicholas,
> 
> On Wed, Jul 8, 2015 at 7:15 AM, Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org> wrote:
> > scanning for trivial bug-patters with coccinelle spatches returned:
> > ./drivers/net/wireless/mwifiex/sta_cmdresp.c:895
> >         WARNING: condition with no effect (if branch == else)
> >
> > originally added in 'commit d8d2f19feb16 ("mwifiex: silence TDLS link
> > delete failure for nonexistent link")' with dev_dbg/dev_err (though
> > with the same message) to differentiate severity and then in 'commit
> > acebe8c10a6e ("mwifiex: change dbg print func to mwifiex_dbg")' all
> > dev_dbg,dev_warn and dev_err got converted to mwifiex_dbg which should
> > thus probably drop this if/else as well.
> >
> > Signed-off-by: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
> > ---
> >
> > If dropping the if/else is not the right thing to do then commit
> > acebe8c10a6e "mwifiex: change dbg print func to mwifiex_dbg" probably
> > needs a review as well.
> >
> > Patch was compile tested with x86_64_defconfig + CONFIG_MWIFIEX=m
> >
> > Patch is against 4.2-rc1 (localversion-next is -next-20150708)
> >
> >  drivers/net/wireless/mwifiex/sta_cmdresp.c |   11 +++--------
> >  1 file changed, 3 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
> > index b645884..e58f900 100644
> > --- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
> > +++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
> > @@ -892,14 +892,9 @@ static int mwifiex_ret_tdls_oper(struct mwifiex_private *priv,
> >         switch (action) {
> >         case ACT_TDLS_DELETE:
> >                 if (reason) {
> > -                       if (!node || reason == TDLS_ERR_LINK_NONEXISTENT)
> > -                               mwifiex_dbg(priv->adapter, ERROR,
> > -                                           "TDLS link delete for %pM failed: reason %d\n",
> > -                                           cmd_tdls_oper->peer_mac, reason);
> > -                       else
> > -                               mwifiex_dbg(priv->adapter, ERROR,
> > -                                           "TDLS link delete for %pM failed: reason %d\n",
> > -                                           cmd_tdls_oper->peer_mac, reason);
> > +                       mwifiex_dbg(priv->adapter, ERROR,
> > +                                   "TDLS link delete for %pM failed: reason %d\n",
> > +                                   cmd_tdls_oper->peer_mac, reason);
> 
> I think reason why we had these 2 different prints is for first
> occurrence in "if" which may be not so serious we used to print with
> dev_dbg and second occurrence in "else" is more serious issue which
> was under dev_err.
> It would be better to use mwifiex_dbg with DBG/MSG in"if" condition
> instead of removing whole if/else.
>

ok - it seemed to me that since the reason was being printed it would be
clear from the error message which case was triggering this message but
you are right that the initial intent to differentiate severity levels
(from 'commit d8d2f19feb16 ("mwifiex: silence TDLS link delete failure
for nonexistent link")' would be better served with your suggestion - I 
just was not clear if this initial reason still holds.

will fix it up and resend.

thx!
hofrat
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
