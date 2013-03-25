From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH regression/bisected] Revert "brcmsmac: support 4313iPA"
Date: Mon, 25 Mar 2013 14:58:21 -0400
Message-ID: <20130325185821.GB17454@tuxdriver.com>
References: <1363603503-2378-1-git-send-email-dh.herrmann@gmail.com>
 <51471B85.5060404@broadcom.com>
 <CANq1E4TsM6yoSt9aELFan0ayEw3PSfYCe+PEe35YFHzZ-9rTuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Piotr Haber <phaber-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANq1E4TsM6yoSt9aELFan0ayEw3PSfYCe+PEe35YFHzZ-9rTuA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 18, 2013 at 02:58:08PM +0100, David Herrmann wrote:
> Hi Piotr
> 
> On Mon, Mar 18, 2013 at 2:49 PM, Piotr Haber <phaber-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
> > On 03/18/13 11:45, David Herrmann wrote:
> >> This reverts commit b6fc28a158076ca2764edc9a6d1e1402f56e1c0c. It breaks
> >> wireless AP reconnection on: (14e4:4727)
> >>   Broadcom Corporation BCM4313 802.11b/g/n Wireless LAN Controller
> >>
> >> Any attempt to reconnect to an AP results in timeouts no matter how near to the
> >> AP I am:
> >>  00:10:40 $nb kernel: wlan0: authenticate with 00:18:39:0a:8e:23
> >>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 1/3)
> >>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 2/3)
> >>  00:10:41 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 3/3)
> >>  00:10:41 $nb kernel: wlan0: authentication with 00:18:39:0a:8e:23 timed out
> >> ---
> >> Hi
> >>
> >> I tried coming up with a fix instead of reverting this commit, but the commit is
> >> way to big for me to understand what's going on. Sorry.
> >>
> >> With linux-3.8 connecting to an AP broke on my machine. I could connect to an AP
> >> one time, but any further attempt resulted in:
> >>  00:10:40 $nb kernel: wlan0: authenticate with 00:18:39:0a:8e:23
> >>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 1/3)
> >>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 2/3)
> >>  00:10:41 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 3/3)
> >>  00:10:41 $nb kernel: wlan0: authentication with 00:18:39:0a:8e:23 timed out
> >>
> >> Even sitting right next to the AP didn't help so I started bisecting and it
> >> turned out to be:
> >>   "brcmsmac: support 4313iPA" b6fc28a158076ca2764edc9a6d1e1402f56e1c0c
> >> Please revert it.
> >>
> >> Thanks
> >> David
> >>
> > Hi,
> > unfortunately this is not a first report of this patch breaking 4313 for some users.
> > I'm pretty confident that it is hardware revision related as we have 4313ePA and iPA boards running
> > successfully in our test setup.
> > Could you aid us in effort of finding the problem by supplying the contents of this debugfs file:
> > <debugfs_mount>/brcmsmac/bcma0:0/hardware
> 
> Hi
> 
> $ cat /sys/kernel/debug/brcmsmac/bcma0\:0/hardware
> board vendor: 185f
> board type: 51a
> board revision: 1408
> board flags: 8402a01
> board flags2: 880
> firmware revision: 262032b
> 
> I can also try partial reverts of that commit, but I really don't know
> which parts might be important.

Are we going to see a fix for this (very) soon?  Or should I just go
ahead and revert this patch?

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
