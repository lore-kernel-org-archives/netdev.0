From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: bluetooth-2.6 2010-09-27
Date: Mon, 27 Sep 2010 20:00:16 -0700 (PDT)
Message-ID: <20100927.200016.226762808.davem@davemloft.net>
References: <20100928023035.GA3033@vigoh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100928023035.GA3033@vigoh>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Date: Mon, 27 Sep 2010 23:30:35 -0300

> And a fix for a deadlock issue between the sk_sndbuf and the backlog
> queue in ERTM. The rest are also needed bug fixes.

This fix is still under discussion.

That change effects quite a few code paths.  And when I looked
at them, I was not at all convinced that dropping the socket
lock like that is safe.

Are you sure there are no pieces of socket or socket related state
that might change under us while we drop that lock, which would thus
make the operation suddenly invalid or cause a state corruption or
crash?

You really need to audit this.
