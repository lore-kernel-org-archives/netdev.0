From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Cleaning up code formatting errors in net/wireless
 pointed out by checkpatch.
Date: Fri, 17 Feb 2012 11:06:02 -0800
Message-ID: <20120217110602.2c4e762a@nehalam.linuxnetplumber.net>
References: <1329492603-3972-1-git-send-email-lfelipe@profusion.mobi>
	<1329504344.584.18.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luis Felipe Strano Moraes <lfelipe@profusion.mobi>,
	linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329504344.584.18.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Feb 2012 10:45:44 -0800
Joe Perches <joe@perches.com> wrote:

> On Fri, 2012-02-17 at 07:30 -0800, Luis Felipe Strano Moraes wrote:
> > These are mostly minor changes and they are being sent as one patch only in
> > order to cause the smallest amount of disruption.
> []
> > diff --git a/net/wireless/core.c b/net/wireless/core.c
> []
> > @@ -668,7 +668,7 @@ void wiphy_unregister(struct wiphy *wiphy)
> >  		mutex_lock(&rdev->devlist_mtx);
> >  		__count = rdev->opencount;
> >  		mutex_unlock(&rdev->devlist_mtx);
> > -		__count == 0;}));
> > +		__count == 0; }));
> 
> Inline statement expressions are pretty unusual
> for kernel sources.  Normally these are used via
> macro.
> 
> I'd try to make the statement expression visually
> distinct.  Something like:
> 
> 	wait_event(rdev->dev_wait,
> 		   ({
> 			   int __count;
> 			   mutex_lock(&rdev->devlist_mtx);
> 			   __count = rdev->opencount;
> 			   mutex_unlock(&rdev->devlist_mtx);
> 			   __count == 0;
> 		   })
> 		  );
> 

I prefer to see this done as an inline function

wait_event(rdev->dev_wait, is_foo_ready(rdev))

Also, in this case wrapping a condition with a mutex really is
meaningless because the state is longer protected out side the
protected region; in other words the mutex here is bogus and
provides no additional protection.
