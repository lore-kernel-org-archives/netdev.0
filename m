From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [rfc | patch 0/6] netpoll: add support for the bonding driver
Date: Fri, 1 Jul 2005 19:43:50 -0400
Message-ID: <17093.54582.647650.438340@segfault.boston.redhat.com>
References: <17093.52306.136742.190912@segfault.boston.redhat.com>
	<20050701233811.GQ12006@waste.org>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261636AbVGAXoR@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050701233811.GQ12006@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

==> Regarding Re: [rfc | patch 0/6] netpoll: add support for the bonding driver; Matt Mackall <mpm@selenic.com> adds:

mpm> On Fri, Jul 01, 2005 at 07:05:54PM -0400, Jeff Moyer wrote:
>> New netpoll function implemented by the network drivers:
>> 
net_device-> netpoll_setup
>> This is required, since the bonding device has to walk through each
>> slave and point its slave_dev->npinfo at the npinfo for the master
>> device.  The reason for this is so that when we're doing the napi
>> polling, we can set the rx_flags appropriately.
>> 
net_device-> netpoll_start_xmit
>> This routine is required since, otherwise, there is no way to intercept
>> packets bound for interfaces that are not ready for them.  Of course, it
>> requires further logic in the bonding driver to then call into the
>> netpoll_send_skb routine (which is a new export).
>> 
>> Note that neither of these pointers has to be filled in by the driver.
>> These functions should only be implemented where needed, and to date,
>> that is only in the bonding driver.
>> 
>> Newly exported are:
>> 
>> netpoll_send_skb This is exported so that the bonding driver can queue a
>> packet to be sent via the real ethernet device it has chosen.
>> 
>> netpoll_poll_dev This is a new routine that was created and exported so
>> that the poll_controller implementation in the bonding driver could poll
>> each of the underlying real devices without duplicating all of the logic
>> that exists internally to netpoll already.
>> 
>> 
>> To test this, as I mentioned above, I wrote a simple module which, upon
>> receipt of any packet, sends out a packet with the message "PONG".  I
>> fired up netcat to send test packets, and receive the responses.  I also
>> loaded the netconsole module for the very same interface, bond0, and
>> issue a series of sysrq-X's, both via sysrq-trigger and via the
>> keyboard.  I did this while simultaneously testing the PING server on an
>> SMP machine.  As things stand, it is very stable in my environment.
>> 
>> And so, the patch set follows.  Any and all comments are appreciated.

mpm> Patches 1, 3, and 6 are unrelated bugfixes and should just go in.

Right.  Sorry I lumped them together.

mpm> I don't like that we rely on queueing to process round trips for PONG.
mpm> Is this really unavoidable?

That's how it works without these patches, too.

mpm> And I think the most controversial thing here is moving locks from
mpm> npinfo into the device.

Well, as I mentioned, that's a bit of an optimization, if you will.

mpm> Not really happy about how incestuous this makes the bonding driver
mpm> with netpoll. I'll try to think more about it over the weekend.

I'd be delighted if you came up with a better way to do things.  However, I
think you'll find that this is about as clean as it gets.

-Jeff
