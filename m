From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't
 work.
Date: Wed, 18 Dec 2013 20:57:26 -0800
Message-ID: <20131219045726.GA3654@cerro.do-not-panic.com>
References: <1534126119.20131217104548@eikelenboom.it>
 <387552477.20131217213319@eikelenboom.it>
 <20131217212709.GB5624@decadent.org.uk>
 <1254825772.20131217224914@eikelenboom.it>
 <CA+55aFxQg6=MAWEkEGz64Hz8OawvPyX=fpBOjY8cGBL5XgB9WQ@mail.gmail.com>
 <52B167F6.5060209@broadcom.com>
 <1387358785.4694.9.camel@jlt4.sipsolutions.net>
 <133955103.20131218114845@eikelenboom.it>
 <20131218194328.GE5705@cerro.do-not-panic.com>
 <4610721898.20131218204546@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Arend van Spriel <arend@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Julian Calaby <julian.calaby@gmail.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4610721898.20131218204546@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 18, 2013 at 08:45:46PM +0100, Sander Eikelenboom wrote:
> 
> Wednesday, December 18, 2013, 8:43:28 PM, you wrote:
> 
> > On Wed, Dec 18, 2013 at 11:48:45AM +0100, Sander Eikelenboom wrote:
> >> 
> >> Wednesday, December 18, 2013, 10:26:25 AM, you wrote:
> >> 
> >> > Hi all,
> >> 
> >> > We really should be asking Luis to look at this who hasn't yet chimed
> >> > in, presumably because he's between jobs (and travelling IIRC)
> >> 
> >> > On Wed, 2013-12-18 at 10:16 +0100, Arend van Spriel wrote:
> >> >> On 12/17/2013 11:06 PM, Linus Torvalds wrote:
> >> >> > We have literally had this *exact* same issue with firmware loading.
> >> >> > Network drivers shouldn't try to load firmware at module load time.
> >> >> > Same deal.
> >> >> 
> >> >> It is kind of a chicken and egg problem for (wireless) networking
> >> >> drivers. To get IFF_UP from the network layer you have to register a
> >> >> netdevice. For wireless drivers this means you have to register a wiphy
> >> >> device with cfg80211 which flags capabilities and optionally are custom
> >> >> regulatory domain. That information depends on the device and firmware
> >> >> used. And there we have a full circle.
> >> 
> >> > This is all really beside the point.
> >> 
> >> > For this CRDA information, the kernel never actually *waits* for it, so
> >> > in the case that there's no reply, it uses the built-in world domain. So
> >> > it's not like request_firmware(), which will block boot forever, but
> >> > it's also not like request_firmware_nowait() which will eventually time
> >> > out and come back with an error if userspace isn't handling it (though
> >> > now that firmware loading is built in ...)
> >> 
> >> > The issue is that it uses the built-in data *forever*, and what Sander
> >> > said was "or it will block forever" but just meant that it never was
> >> > able to do any further updates.
> >> 
> >> > It *doesn't* actually block the boot process or such. Everything Linus
> >> > said is true but seems to have been written in understanding "blocks" as
> >> > "blocking the boot process", rather than "blocking further updates".
> >> 
> >> > Regardless of this, even blocking further updates is a really bad idea.
> >> > There are a few ways to handle this, but I'll let Luis poke at that.
> >> 
> >> Your description is correct, sorry if I was not clear.
> 
> > We have a timeout handler for this, I'll check to see what's going on
> > by trying to reproduce on my end. Are you using wireless-testing ?
> 
> Originally 3.13-rc4, after that i tried with 3.13-rc4 with wireless-next pulled on top of it
> (since there were major changes to reg.c) but the problem occurs with both.

OK I can reproduce and am working on the cleanest solution. Thanks for
your report, I'll Cc ya when I have something reasonable baked up,
hopefully rather soon!

  Luis
