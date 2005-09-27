From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Debugging neighbour.c: timers
Date: Mon, 26 Sep 2005 17:48:05 -0700 (PDT)
Message-ID: <20050926.174805.31061388.davem@davemloft.net>
References: <20050907.141847.95180907.davem@davemloft.net>
	<43387327.20006@candelatech.com>
	<20050927003845.GA8273@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, ja@ssi.bg, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964779AbVI0As1@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20050927003845.GA8273@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "A.N.Kuznetsov" <kuznet@ms2.inr.ac.ru>
Date: Tue, 27 Sep 2005 04:38:45 +0400

> Actually, when this code was written, add_timer() behaved differently,
> double add_timer() was prohibited and it printked
> "bug: kernel timer added twice at...".

Yes, it calls __mod_timer() now.  That's quite bad and
the debugging check should be re-added I think.

Is there some reason why we want add_timer() to behave like
__mod_timer(timer, timer->expires)?  I can't see any...

So perhaps we should add the simple BUG_ON(timer->pending) check to
include/linux/timer.h:add_timer()

add_timer_on() does this check btw....
