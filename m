From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 10:32:40 -0700
Message-ID: <m11v801tfr.fsf@fess.ebiederm.org>
References: <201010081353.28056.hans.schillstrom@ericsson.com>
	<201010081428.37639.hans.schillstrom@ericsson.com>
	<m1y6a81vms.fsf@fess.ebiederm.org>
	<20101008.102012.226761665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hans.schillstrom@ericsson.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47962 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab0JHRcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:32:46 -0400
In-Reply-To: <20101008.102012.226761665.davem@davemloft.net> (David Miller's
	message of "Fri, 08 Oct 2010 10:20:12 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 08 Oct 2010 09:45:15 -0700
>
>> My hunch is that we have dst entry problems, as I know those hop network
>> interfaces when we destroy network devices, but I have seen weird issues
>> with the route cache as well.
>
> While we're on this topic, can someone explain to me what the special
> CONFIG_NET_NS code in net/ipv4/route.c:rt_do_flush() is trying to
> accomplish?
>
> If the issue is that there is an implicit ordering of releasing of
> 'dst' entries that must be maintained, we really ought to formalize
> it (f.e. with dependency pointers or something like that).

It is just dealing with not flushing the entire routing cache, just the
routes that have expired.  Which prevents one network namespace from
flushing it's routes and DOS'ing another.

The practical consequence is that the hash chains have to be picked
apart with some entries kept and some released based upon
rt_is_expired().

I went through it a year or so ago with a fine tooth comb and it made
sense and seems correct, but it does seem overly convoluted.

Eric

