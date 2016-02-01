From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] mac80211: fix memory leak
Date: Mon, 1 Feb 2016 09:55:48 +0530
Message-ID: <20160201042548.GA4072@sudip-pc>
References: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
 <CAGRGNgXc9PtYY=hb8nNRt4T5YGm2vexcJ01Z1fCCcb=57WRZ3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGRGNgXc9PtYY=hb8nNRt4T5YGm2vexcJ01Z1fCCcb=57WRZ3g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 01, 2016 at 11:03:35AM +1100, Julian Calaby wrote:
> Hi Sudip,
> 
> On Fri, Jan 29, 2016 at 8:49 PM, Sudip Mukherjee
> <sudipm.mukherjee@gmail.com> wrote:
> > On error we jumped to the error label and returned the error code but we
> > missed releasing sinfo.
> >
> > Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> 
> Should the From: and Signed-off-by: email addresses be the same?

I think 2 years back I had a long discussion with Greg about this and
since then I al submitting patches like this. A small summayg of the
problem from that discussion:

"we have strict DMARC check for the corporate mail server. DMARC =
domain based message authentication.
So the mail i sent reached all the list subscriber from a different
server than our designated server, and as a result it is marked as spam
in many places and I have already received a few complaints regarding
that."

> 
> > ---
> >  net/mac80211/sta_info.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
> > index 6c198e6..36e75c4 100644
> > --- a/net/mac80211/sta_info.c
> > +++ b/net/mac80211/sta_info.c
> > @@ -561,6 +561,7 @@ static int sta_info_insert_finish(struct sta_info *sta) __acquires(RCU)
> >         __cleanup_single_sta(sta);
> >   out_err:
> >         mutex_unlock(&local->sta_mtx);
> > +       kfree(sinfo);
> >         rcu_read_lock();
> >         return err;
> >  }
> 
> Looks sane to me. I must note that the bug this is fixing is only in
> the mac80211-next tree.
> 
> Fixes: 5fe74014172d ("mac80211: avoid excessive stack usage in sta_info")
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

thanks

regards
sudip
