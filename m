From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: queue console messages to send later
Date: Mon, 07 Jun 2010 16:52:24 -0700 (PDT)
Message-ID: <20100607.165224.25140316.davem@davemloft.net>
References: <1275940248.26597.70.camel@calx>
	<20100607130015.15555744@nehalam>
	<1275942091.26597.85.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, fleitner@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, fubar@us.ibm.com,
	fbl@sysclose.org, gospo@redhat.com, nhorman@tuxdriver.com,
	jmoyer@redhat.com, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: mpm@selenic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275942091.26597.85.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Mon, 07 Jun 2010 15:21:31 -0500

> Open to suggestions. The locks in question are driver-internal. There
> also may not be any actual recursion taking place:
> 
> driver path a takes private lock x
> driver path a attempts printk
> printk calls into netconsole
> netconsole calls into driver path b
> driver path b attempts to take lock x -> deadlock
> 
> So we can't even try to walk back the stack looking for such nonsense.
> Though we could perhaps force queuing of all messages -from- the driver
> bound to netconsole. Tricky, and not quite foolproof.

Look, this is all nonsense talk.

This is only coming about because of the recent discussions about
bonding, so let's fix bonding's locking.  I've made concrete
suggestions on converting it's rwlocks over to spinlocks and RCU to
fix the specific problem bonding has.

Every time we hit some new locking issue the knee jerk reaction is
to do something stupid to the generic netconsole code instead of
fixing the real source of the problem.
