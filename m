From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: custom ioctl-based interface to control LED in networking (was
 Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode)
Date: Wed, 24 Feb 2016 12:01:37 +0100
Message-ID: <1456311697.2050.23.camel@sipsolutions.net>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
	 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
	 <20160223204525.GC16961@amd> <1456260914.9910.34.camel@sipsolutions.net>
	 <20160223214501.GA22501@amd> <1456304509.2050.15.camel@sipsolutions.net>
	 <20160224104611.GB31302@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: Pavel Machek <pavel@ucw.cz>, rpurdie@rpsys.net,
	j.anaszewski@samsung.com, linux-leds@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160224104611.GB31302@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-24 at 11:46 +0100, Pavel Machek wrote:

> If you want different trigger, implement different trigger. If you
> want to indicate all but wifi, implement all but wifi, and then
> userspace can select it by writing trigger name. 

This is still mostly a strawman, since userspace cannot have a database
of LEDs that indicate airplane mode.

I'm sure you'd also not like to see 2**7 triggers implemented in rfkill
to cover all the possibilities.

> If you want complete
> userspace control, fine, but we have standard interface and it is not
> ioctl.

The "standard interface" is usable if you really just want to driver a
single LED and you know which one.

I think you're looking at this the wrong way, focusing too much on the
LED aspect.

Really what you have here is a concept of "airplane mode", and that
concept is specific to the rfkill subsystem. This happens to affect
mostly an LED trigger, today, but as a concept it's something that
*should* be managed within the rfkill subsystem.

> Besides, the series really should have been Cc-ed to LED
> people, too.

That's simply unreasonable, you're essentially saying that any user of
any kernel infrastructure should be Cc'ed to the implementer of that
infrastructure... 9/10 patches in this series aren't even LED specific,
only the *previous* patch, the one that tied the "airplane mode"
concept to an LED trigger in a very standard way had anything to do
with LED triggers at all.

johannes
