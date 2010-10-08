From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 09:45:15 -0700
Message-ID: <m1y6a81vms.fsf@fess.ebiederm.org>
References: <201010071048.12817.hans.schillstrom@ericsson.com>
	<4CAEFE2C.3010007@free.fr>
	<201010081353.28056.hans.schillstrom@ericsson.com>
	<201010081428.37639.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49323 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121Ab0JHQpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:45:20 -0400
In-Reply-To: <201010081428.37639.hans.schillstrom@ericsson.com> (Hans
	Schillstrom's message of "Fri, 8 Oct 2010 14:28:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans.schillstrom@ericsson.com> writes:

> Hi Eric,
> Any advice how to trace this down ?
> This rollback_registered_many() seems to have on the lists before...

That is just the core piece that does device registration.

> All IPv4 and IPv6 tunnels causes this crash, all you have to do is load the tunnel module(s)
> enter a new ns and exit from it.

Ouch.  

> Have not tested any more devices than tunnels, 
> I did an "ip link delete" on my macvlans before exiting the ns.

My hunch is that we have dst entry problems, as I know those hop network
interfaces when we destroy network devices, but I have seen weird issues
with the route cache as well.

Grumble.

Eric
