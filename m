From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Tue, 18 Jun 2013 09:52:41 -0700
Message-ID: <1371574361.3252.259.camel@edumazet-glaptop>
References: <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 <1361351703.8629.5.camel@jlt4.sipsolutions.net>
	 <20130223061414.GA16883@merlins.org>
	 <1361912099.8440.21.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361912099.8440.21.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-26 at 21:54 +0100, Johannes Berg wrote:
> On Fri, 2013-02-22 at 22:14 -0800, Marc MERLIN wrote:
> > On Wed, Feb 20, 2013 at 10:15:03AM +0100, Johannes Berg wrote:
> > > On Wed, 2013-02-20 at 10:12 +0100, Johannes Berg wrote:
> > > > On Tue, 2013-02-19 at 08:21 -0800, Eric Dumazet wrote:
> > > > > On Tue, 2013-02-19 at 11:03 +0100, Johannes Berg wrote:
> > > > > > On Mon, 2013-02-18 at 21:17 -0800, Eric Dumazet wrote:
> > > > > > 
> > > > > > > > chrome: page allocation failure: order:1, mode:0x4020
> > > > > > > > Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
> > > > > > > > Call Trace:
> > > > > > > >  <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
> > > > > > 
> > > > > > > You could try to load iwlwifi with amsdu_size_8K set to 0 (disable)
> > > > > > > 
> > > > > > > It should hopefully use order-0 pages
> > > > > > 
> > > > > > It will, do that then, unfortunately it can't switch at runtime because
> > > > > > it advertised this support to the access point or clients.
> > > > > 
> > > > > What are the drawbacks of setting amsdu_size_8K to 0 by default ?
> > > > 
> > > > We're discussing this now, the only downside would be that we couldn't
> > > > receive 8k A-MSDUs. Thing is, practically nobody uses A-MSDU anyway, and
> > > > even when I suspect the difference between 4k and 8k won't be huge.
> > > 
> > > OTOH, this affects the protocol, and when you really can't allocate any
> > > order-1 pages you pointed out yourself that many other things also won't
> > > work, so I'm not really sure it makes a big difference if we change the
> > > driver?
> > 
> > That as an unscientific test, but when I did the NFS eats all my pages
> > test using ethernet, my system didn't hang like it did with iwlagn.
> > 
> > So while the NFS code is definitely doing something wrong when it uses
> > its default huge buffers, the e1000e code deals with it without hanging
> > my system.
> > 
> > So thanks for trying to improve the iwlagn code to avoid those system
> > lockups.
> 
> We'll be submitting a patch to make single pages default.

Do you think the same change would be possible for
drivers/net/wireless/iwlegacy/4965-mac.c ?

Thanks !


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
