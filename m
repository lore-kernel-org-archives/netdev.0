From: David Miller <davem@davemloft.net>
Subject: Re: [build bug] drivers/built-in.o: In function
 `rt2x00leds_resume': : undefined reference to `led_classdev_resume'
Date: Sun, 20 Apr 2008 02:47:04 -0700 (PDT)
Message-ID: <20080420.024704.02026708.davem@davemloft.net>
References: <20080420081302.GA11954@elte.hu>
	<20080420.020557.231970202.davem@davemloft.net>
	<200804201131.01504.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl
To: ivdoorn@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200804201131.01504.IvDoorn@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>
Date: Sun, 20 Apr 2008 11:31:00 +0200

> Not sure about it, but doesn't LEDS_CLASS depend on NEW_LEDS ?
> Which would make selecting LEDS_CLASS broken when NEW_LEDS isn't enabled?

True, what an awful dependency chain.

NEW_LEDS requires HAS_IOMEM.  This is to handle platforms like
S390 and UM.

But I think this protection is overboard.  Specific drivers
might need IOMEM functionality, but the basic infrastructure
does not.

All of the core infrastrucure and generic LEDS facilities, including
NEW_LEDS, LEDS_CLASS, and LEDS_TRIGGERS, don't need the IOMEM
protection.

And neither do the LED device drivers, they already each have a
depenency for a specific platform.

You could even imagine a hypervisor based LED driver that a platform
like S390, which does not enable HAS_IOMEM, might want to support
under this infrastructure.

I think NEW_LEDS can be completely eliminated.
