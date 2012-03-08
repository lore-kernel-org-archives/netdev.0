From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference
 on tty_close
Date: Thu, 08 Mar 2012 09:45:22 -0800
Message-ID: <1331228722.14217.7.camel@aeonflux>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
	 <1331136120-27075-2-git-send-email-jhovold@gmail.com>
	 <1331148797.3392.191.camel@aeonflux> <20120308115721.GB4497@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120308115721.GB4497@localhost>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johan,

> > > Do not close protocol driver until device has been unregistered.
> > > 
> > > This fixes a race between tty_close and hci_dev_open which can result in
> > > a NULL-pointer dereference.
> > > 
> > > The line discipline closes the protocol driver while we may still have
> > > hci_dev_open sleeping on the req_lock mutex resulting in a NULL-pointer
> > > dereference when lock is acquired and hci_init_req called.
> 
> [...]
> 
> > what kernel version is this against? Our changes in bluetooth-next fixed
> > some of the destruct handling.
> 
> This is against the latest rc as it needs to be fixed in 3.3, but I
> missed a dependency to bluetooth-next as you point out below.
> 
> > Also hci_unregister_dev should be calling the destruct handler and thus
> > your change is now accessing hu but it got freed already.
> 
> You're right, my patch depends on 010666a126fc ("Bluetooth: Make
> hci-destruct callback optional") and 797fe796c4 ("Bluetooth: uart-ldisc:
> Fix memory leak and remove destruct cb") from bluetooth-next. 
> 
> But since the latter one fixes a memory leak it should have been marked
> for stable as well as pushed to Linus for 3.3, right?

we need to look into this and propose patches for -stable. Is your
problem still present with bluetooth-next or not?

Regards

Marcel
