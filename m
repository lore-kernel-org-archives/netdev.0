From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't
 work.
Date: Wed, 18 Dec 2013 10:29:10 -0800
Message-ID: <20131218182910.GA5705@cerro.do-not-panic.com>
References: <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it>
 <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <1818324675.20131211175350@eikelenboom.it>
 <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com>
 <1342235583.20131211182804@eikelenboom.it>
 <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
 <871324710.20131211191104@eikelenboom.it>
 <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
 <1937118387.20131216122200@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1937118387.20131216122200@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 12:22:00PM +0100, Sander Eikelenboom wrote:
> 
> Wednesday, December 11, 2013, 7:38:50 PM, you wrote:
> 
> > On Wed, Dec 11, 2013 at 7:11 PM, Sander Eikelenboom
> > <linux@eikelenboom.it> wrote:
> >>
> >> Wednesday, December 11, 2013, 6:53:07 PM, you wrote:
> >>
> >>> The best way to address all this is by automatic region awareness and
> >>> doing the right thing on devices, this however requires good
> >>> architecture / calibration data  / etc and all that needs to be
> >>> verified by the system integrators, and finally they need to be
> >>> certified. If you want to hack your firmware and software go at it,
> >>> just be aware there are reasons for things.
> >>
> >> Well the general problem seems to be "we don't trust the user" so we FORCE him to the lowest
> >> common denominator (without a way to overrule that) so he is forced to operate *well* within the law.
> 
> > Its simply stupid to have the user be involved, period, the fact that
> > a user would be involved should only be for testing or helping
> > compliance for a busted device, development, research and obviously
> > hacking. Linux allows all these but by default a device with firmware
> > and a custom regdomain that will barf if you try to use a channel that
> > is not allowed is a restriction in firmware. Feel free to reverse
> > engineer that if you don't like it but it just won't be supported or
> > go upstream. Now, the common denominator is generally optimized for
> > best performance as well so you shouldn't have to do anything, and for
> > APs -- this is typically carefully crafted for a region, also highly
> > optimized.
> 
> >>>>> It doesn't seem like you are getting your original requests getting
> >>>>> processed, so I don't think CRDA is passing it. Can you verify running
> >>>>> from CRDA code:
> >>>>
> >>>> They don't get processed unless i remove the return from the code as i indicated.
> >>>> If i remove that return it processes the request.
> >>>>
> >>>>> ./regdbdump /usr/lib/crda/regulatory.bin
> >>>>
> >>>> Although it's in a different location on Debian, /lib/crda/regulatory.bin
> >>>> the dump seems fine.
> >>
> >>> OK thanks. Can you send a patch of what exact change you made, it was
> >>> unclear from the paste you made.
> >>
> >>> diff -u file.c.orig file.c
> >>
> >> Well i just did a pull from wireless-next, to try Avinash Patil's patch.
> >> net/wireless/reg.c had already changed much so i couldn't apply his patch without.
> >>
> >> With his patch it sets the regulatory domain, although as now expected i still can not use channels 12 and 13 yet,
> >> probably due to those firmware restrictions.
> 
> > Its unclear what results you got, and yeah if the device is restricted
> > then its just the fw telling the driver its channels and you can't use
> > them. That's it. You won't be able to override information then unless
> > you hack the firmware
> 
> Ping ?
> 
> Is there anymore information you need to *fix* the problem ?

I was away on Travel back home, and will soon be traveling to
visit family so e-mail replies will be delayed, I'll jump on this
thread now but in short:

You are confusing the main issue you reported (cannot override regulatory)
as a software issue rather than a firmware issue with intel firmware, you are
also making claims and making people believe things work in different ways
(I'll clarify things there, proper regulatory support without CRDA works, CRDA
is just a helper, we also do have a timeout on requests). Lastly there is one
issue that may be a software issue but I cannot reproduce which I am
interested in getting down to the bottom to.

I'll dive into the different things now.

  Luis
