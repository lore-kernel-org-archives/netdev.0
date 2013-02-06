From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: mac80211/cfg.c: fix error using of sizeof()
Date: Wed, 06 Feb 2013 20:28:29 +0100
Message-ID: <1360178909.7910.61.camel@jlt4.sipsolutions.net>
References: <1360167826-29265-1-git-send-email-dinggnu@gmail.com>
	 <20130206.133304.809962323533002767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dinggnu@gmail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130206.133304.809962323533002767.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-06 at 13:33 -0500, David Miller wrote:
> From: Cong Ding <dinggnu@gmail.com>
> Date: Wed,  6 Feb 2013 17:23:45 +0100
> 
> > Using 'sizeof' on array given as function argument returns size of a pointer
> > rather than the size of array.
> > 
> > Signed-off-by: Cong Ding <dinggnu@gmail.com>
> > ---
> >  net/mac80211/cfg.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
> > index 661b878..af561d5 100644
> > --- a/net/mac80211/cfg.c
> > +++ b/net/mac80211/cfg.c
> > @@ -2058,7 +2058,8 @@ static int ieee80211_set_mcast_rate(struct wiphy *wiphy, struct net_device *dev,
> >  {
> >       struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
> >  
> > -     memcpy(sdata->vif.bss_conf.mcast_rate, rate, sizeof(rate));
> > +     memcpy(sdata->vif.bss_conf.mcast_rate, rate,
> > +                     sizeof(int) * IEEE80211_NUM_BANDS);
> >  
> 
> This is not indented properly.  The "sizeof(int..." should start at the
> first column after the openning parenthesis of the memcpy() call.

Yeah I fixed it when I applied it ... oh well.

johannes
