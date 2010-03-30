From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] net/wireless/libertas: do not call wiphy_unregister()
 w/o wiphy_register()
Date: Tue, 30 Mar 2010 10:52:53 +0200
Message-ID: <20100330085253.GL30801@buzzloop.caiaq.de>
References: <1269875658-3324-1-git-send-email-daniel@caiaq.de>
 <201003300849.07441.hs4233@mail.mn-solutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Holger Schurig <hs4233@mail.mn-solutions.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201003300849.07441.hs4233@mail.mn-solutions.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 08:49:07AM +0200, Holger Schurig wrote:
> > The libertas driver calls wiphy_unregister() without a prior
> > wiphy_register() when a devices fails initialization. Fix this by
> > introducing a private flag.
> 
> Nice.
> 
> However, I wonder: do we really need a private variable?  Does each driver 
> introduce a private variable for this?

I didn't check other drivers thoroughly. I just saw the comment on the
function which does the wiphy allocation and considered libertas to be
special in the way it deals with the wireless core:

/*
 * At this time lbs_private *priv doesn't even exist, so we just allocate
 * memory and don't initialize the wiphy further. This is postponed until we
 * can talk to the firmware and happens at registration time in
 * lbs_cfg_wiphy_register().
 */

And as I didn't find any function to tell me whether a wiphy has been
registered and not just allocated, I saw no other way than manually
track what the libertas driver does.

If there's any better solution, I'd happily test it.

Thanks,
Daniel
