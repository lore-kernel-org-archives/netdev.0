From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] Cleaning up code formatting errors in net/wireless
 pointed out by checkpatch.
Date: Mon, 20 Feb 2012 11:45:22 +0100
Message-ID: <1329734722.3458.7.camel@jlt3.sipsolutions.net>
References: <1329492603-3972-1-git-send-email-lfelipe@profusion.mobi>
	 <1329504344.584.18.camel@joe2Laptop>
	 <20120217110602.2c4e762a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Luis Felipe Strano Moraes <lfelipe-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120217110602.2c4e762a-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-02-17 at 11:06 -0800, Stephen Hemminger wrote:

> > I'd try to make the statement expression visually
> > distinct.  Something like:
> > 
> > 	wait_event(rdev->dev_wait,
> > 		   ({
> > 			   int __count;
> > 			   mutex_lock(&rdev->devlist_mtx);
> > 			   __count = rdev->opencount;
> > 			   mutex_unlock(&rdev->devlist_mtx);
> > 			   __count == 0;
> > 		   })
> > 		  );
> > 
> 
> I prefer to see this done as an inline function
> 
> wait_event(rdev->dev_wait, is_foo_ready(rdev))
> 
> Also, in this case wrapping a condition with a mutex really is
> meaningless because the state is longer protected out side the
> protected region; in other words the mutex here is bogus and
> provides no additional protection.

I don't really care about all the changes suggested here -- feel free to
make them. One thing I'd like to point out though is that generally the
mutex might serve a purpose even here. In this specific case, it
currently doesn't, but I still think it's safer to keep it in case
somebody modifies other code. The case where it matters is when the
modification of the "opencount" variable isn't the last thing that
happens in a locked section, but you here want or need to wait for
everything happening in that section to be done.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
