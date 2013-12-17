From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Tue, 17 Dec 2013 14:06:06 -0800
Message-ID: <CA+55aFxQg6=MAWEkEGz64Hz8OawvPyX=fpBOjY8cGBL5XgB9WQ@mail.gmail.com>
References: <1342235583.20131211182804@eikelenboom.it>
	<CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
	<871324710.20131211191104@eikelenboom.it>
	<CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
	<1937118387.20131216122200@eikelenboom.it>
	<52AEE60B.6030509@broadcom.com>
	<19210260274.20131216135644@eikelenboom.it>
	<CAGRGNgXHemM2FfnXgW5RbzhFT+9SfUfVkjdysK3+=_u3hWSacw@mail.gmail.com>
	<1534126119.20131217104548@eikelenboom.it>
	<387552477.20131217213319@eikelenboom.it>
	<20131217212709.GB5624@decadent.org.uk>
	<1254825772.20131217224914@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Julian Calaby <julian.calaby@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1254825772.20131217224914@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 17, 2013 at 1:49 PM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
>
> So if i combine the two .. it's essentially just a very bad idea to compile the wireless stuff in.
> It needs a access to a userland program at module load time, or it will block forever.

No, it's a very stupid module if it does that.

It should require the crda hook not at module load time, but at first
ifconfig time.

We've had bugs like this before.  Doing user-mode callbacks at module
loading time is a disaster exactly because it doesn't work well with
built-in modules.

The fact that those things apparently also don't time out or notice
when they fail seems to then just exacerbate the bad decision.

We have literally had this *exact* same issue with firmware loading.
Network drivers shouldn't try to load firmware at module load time.
Same deal.

What's the broken path? Is this driver-specific, or is it generic to
the 802.11 code?

                Linus
