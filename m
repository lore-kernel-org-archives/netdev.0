From: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] mac80211: make max_network_latency notifier
 atomic safe
Date: Wed, 9 Jun 2010 17:37:40 +0200
Message-ID: <20100609173740.3851c6a5@schatten.dmk.lab>
References: <1276074915-26879-1-git-send-email-florian@mickler.org>
	<1276076287.3727.15.camel@jlt3.sipsolutions.net>
	<20100609122050.1dd18132@schatten.dmk.lab>
	<1276080128.14580.5.camel@jlt3.sipsolutions.net>
	<20100609141643.14e9aedc@schatten.dmk.lab>
	<1276086425.14580.14.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pm list <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	james.bottomley-l3A5Bk7waGM@public.gmane.org, markgross-FexmcLCpFRVAfugRpC6u6w@public.gmane.org,
	mgross-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Javier Cardona <javier-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Rui Paulo <rpaulo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1276086425.14580.14.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 09 Jun 2010 14:27:05 +0200
Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

> On Wed, 2010-06-09 at 14:16 +0200, Florian Mickler wrote:
> 
> > That was also my first idea, but then I thought about qos and thought
> > atomic notification are necessary.
> > Do you see any value in having atomic notification? 
> > 
> > I have the following situation before my eyes:
> > 
> > 	Driver A gets an interrupt and needs (to service that
> > 	interrupt) the cpu to guarantee a latency of X because the
> > 	device is a bit icky.
> > 
> > Now, in that situation, if we don't immediately (without scheduling in
> > between) notify the system to be in that latency-mode the driver won't
> > function properly. Is this a realistic scene?
> > 
> > At the moment we only have process context notification and only 2
> > listeners.
> > 
> > I think providing for atomic as well as "relaxed" notification could be
> > useful. 
> > 
> > If atomic notification is deemed unnecessary, I have no
> > problems to just use schedule_work() in update request.
> > Anyway, it is probably best to split this. I.e. first make
> > update_request callable from atomic contexts with doing the
> > schedule_work in update_request and then
> > as an add on provide for constraints_objects with atomic notifications.
> 
> Well I remember http://thread.gmane.org/gmane.linux.kernel/979935 where
> Mark renamed things to "request" which seems to imply to me more of a
> "please do this" than "I NEED IT NOW!!!!!".
> 
> johannes

Yes. I just posted a version which uses schedule_work().
Just FYI, James has also posted his version which uses either a blocking
or an atomic notifier chain.
http://article.gmane.org/gmane.linux.kernel/996813

Cheers,
Flo

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
