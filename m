From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't
 work.
Date: Wed, 18 Dec 2013 10:54:53 -0800
Message-ID: <20131218185453.GB5705@cerro.do-not-panic.com>
References: <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it>
 <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <1818324675.20131211175350@eikelenboom.it>
 <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com>
 <1342235583.20131211182804@eikelenboom.it>
 <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
 <871324710.20131211191104@eikelenboom.it>
 <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
 <716357837.20131211200651@eikelenboom.it>
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
In-Reply-To: <716357837.20131211200651@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 08:06:51PM +0100, Sander Eikelenboom wrote:
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
> Well how about a car maker shipping al his cars capped to say 10 miles
> an hour, because somewhere in the world that's the lowest. So to
> prevent you from breaking the law we will cap your 500HP engine, owh
> in your country you have a higher speedlimit, ah wel bad luck for you
> then.  We need to enforce this so no one is going to brake any law any
> where.

Don't mix apples and oranges as in this case it does not help. Some
802.11 devices are capable of doing things dynamically and the dynamics
of that can exist in firmware or the driver. We have to create APIs to
support both, and we have no control over devices that have restrictions
in firmware unless the firmware is open as with ath9k_htc or if the
firmware is reversed engineered. In the end my own advice to 802.11
vendors has always been that the restictions should be kept in the
driver as otherwise they cannot grow / extend to support new regulatory
rules / changes or new countries, the code is also complex and simply a
true waste in firmware. What vendors do is up to them though, Linux
just needs to support all these different types of choices well.

> It's just plain stupid in my opinion (but not something linux can do
> much about, but it's about enforcing this stuff in firmware in general
> and thinking too much for the user (fine if you are capable to do so,
> but in this case clearly not, since there is no automatic way to
> detect in which country the device is, except by relying on user
> input).

If you are arguing against regulatory in firmware -- I agree, that's
plainly stupid, but we can't do anything about it other than reverse
engineer the solutions or proove that we can remain regulatory sane
even if we have implemented the solution in the driver, which I can
clearly stand behind that statement today. What you say about user
knowing better or having to be involved is debatable and I think its
frankly stupid to require any user input for location. The future
architecture for regulatory should simply be fully automatic with
a huge bunch of heuristics to figure out the exact ISO3166-alpha2,
today we have that either programmed in, rely on it from the country
IE, or we get it from the cellular network (LTE, etc). User input
is another source but in the US and JP its now allowed. Cellular
input for trusting regulatory is new and in the US its expected
you go to some extra lenghts with the FCC to get that device
complaint. Linux allows for all these, and we can grow to support
more.

Keep in mind that in Linux we also allow users to say fsck it,
and insist that they know what is best but that then will depend
on what the firmware allows too. Linux allows for it all, what vendors
do is out of our control unless we have influence. Fortunately
we've had quite a bit of influence though and its all been for the
better for users.

Your main issue is where regulatory is in firmware and I also agree
that's silly. We can't do anything over that unless we had firmware
source code or the firmware was reversed engineered. We can also
convince folks that code is simply a waste in firmware and that
we have better controls and features in kernel, which we do.

> Why just don't set the safe and restricted value on boot and
> let the user overrule that if he wishes.  (that means the user has to
> invoke a action, so he also should be aware of the consequences).

Some countries explicitly don't allow user input for regulatory. JP And
US are two of those countries. Drivers can allow support for this and
give developers / testers the flexibility to test things in controlled
ways, see CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS and also see
CONFIG_ATH_REG_DYNAMIC_USER_CERT_TESTING. This is purely driver
specific though and its up to each device driver to use APIs that
give this flexibility in ways that are suitable and agreeable with
their strategy.

We can't change laws, but we can at least provide proper architecture
to address all possibilities. We support it all. Vendors have to decide
what to do and that is out of our direct control.

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
> > you hack the firmware.
> 
> Without the patch:
> 
> - "iw reg get" gives country 00
> - now do a "iw reg set US", no error so it should be fine
> - now do a "iw reg get" .. gives country 00 again, so it has not been set to the country requested.
> 
> With the patch:
> 
> - "iw reg get" gives country 00
> - now do a "iw reg set US", no error so it should be fine
> - now do a "iw reg get" .. gives country US, so it has been set to the country requested.

I'd like to get to the bottom of this. Lets focus on this now. Can you
provide the kernel you used? I'd like to reproduce, I can't right now.

  Luis
