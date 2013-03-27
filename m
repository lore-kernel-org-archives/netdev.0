From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH regression/bisected] Revert "brcmsmac: support 4313iPA"
Date: Wed, 27 Mar 2013 10:56:55 -0400
Message-ID: <20130327145654.GA1868@tuxdriver.com>
References: <1363603503-2378-1-git-send-email-dh.herrmann@gmail.com>
 <51471B85.5060404@broadcom.com>
 <CANq1E4TsM6yoSt9aELFan0ayEw3PSfYCe+PEe35YFHzZ-9rTuA@mail.gmail.com>
 <20130325185821.GB17454@tuxdriver.com>
 <51516AD4.8080306@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Herrmann <dh.herrmann@gmail.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>
To: Piotr Haber <phaber@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51516AD4.8080306@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 26, 2013 at 10:31:00AM +0100, Piotr Haber wrote:
> On 03/25/13 19:58, John W. Linville wrote:
> > On Mon, Mar 18, 2013 at 02:58:08PM +0100, David Herrmann wrote:
> >> Hi Piotr
> >>
> >> On Mon, Mar 18, 2013 at 2:49 PM, Piotr Haber <phaber@broadcom.com> wrote:
> >>> On 03/18/13 11:45, David Herrmann wrote:
> >>>> This reverts commit b6fc28a158076ca2764edc9a6d1e1402f56e1c0c. It breaks
> >>>> wireless AP reconnection on: (14e4:4727)
> >>>>   Broadcom Corporation BCM4313 802.11b/g/n Wireless LAN Controller
> >>>>
> >>>> Any attempt to reconnect to an AP results in timeouts no matter how near to the
> >>>> AP I am:
> >>>>  00:10:40 $nb kernel: wlan0: authenticate with 00:18:39:0a:8e:23
> >>>>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 1/3)
> >>>>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 2/3)
> >>>>  00:10:41 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 3/3)
> >>>>  00:10:41 $nb kernel: wlan0: authentication with 00:18:39:0a:8e:23 timed out
> >>>> ---
> >>>> Hi
> >>>>
> >>>> I tried coming up with a fix instead of reverting this commit, but the commit is
> >>>> way to big for me to understand what's going on. Sorry.
> >>>>
> >>>> With linux-3.8 connecting to an AP broke on my machine. I could connect to an AP
> >>>> one time, but any further attempt resulted in:
> >>>>  00:10:40 $nb kernel: wlan0: authenticate with 00:18:39:0a:8e:23
> >>>>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 1/3)
> >>>>  00:10:40 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 2/3)
> >>>>  00:10:41 $nb kernel: wlan0: direct probe to 00:18:39:0a:8e:23 (try 3/3)
> >>>>  00:10:41 $nb kernel: wlan0: authentication with 00:18:39:0a:8e:23 timed out
> >>>>
> >>>> Even sitting right next to the AP didn't help so I started bisecting and it
> >>>> turned out to be:
> >>>>   "brcmsmac: support 4313iPA" b6fc28a158076ca2764edc9a6d1e1402f56e1c0c
> >>>> Please revert it.
> >>>>
> >>>> Thanks
> >>>> David
> >>>>
> >>> Hi,
> >>> unfortunately this is not a first report of this patch breaking 4313 for some users.
> >>> I'm pretty confident that it is hardware revision related as we have 4313ePA and iPA boards running
> >>> successfully in our test setup.
> >>> Could you aid us in effort of finding the problem by supplying the contents of this debugfs file:
> >>> <debugfs_mount>/brcmsmac/bcma0:0/hardware
> >>
> >> Hi
> >>
> >> $ cat /sys/kernel/debug/brcmsmac/bcma0\:0/hardware
> >> board vendor: 185f
> >> board type: 51a
> >> board revision: 1408
> >> board flags: 8402a01
> >> board flags2: 880
> >> firmware revision: 262032b
> >>
> >> I can also try partial reverts of that commit, but I really don't know
> >> which parts might be important.
> > 
> > Are we going to see a fix for this (very) soon?  Or should I just go
> > ahead and revert this patch?
> > 
> I cannot reproduce the issue on a set of devices we have here (3 different 4313 ePA models).
> Some of the devices that are reported to be broken are being shipped to us.
> So I would say we need around 2 weeks at least to resolve this (if we reproduce the problem and find
> a fix).
> Not sure this is soon enough.
> If not please go ahead an revert the patch.

I am reverting the patch.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
