From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH net-next 0/4] batch calls to fib_flush and arp_ifdown
Date: Mon, 4 Jan 2016 17:12:08 -0800
Message-ID: <CAO7SqHBhkSFi77-ys5zs_dKsU=62kLZYCb0jhetnJddbL8gFuA@mail.gmail.com>
References: <1451949056-15500-1-git-send-email-noureddine@arista.com>
	<87oad0rhh8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36281 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbcAEBMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 20:12:10 -0500
Received: by mail-wm0-f41.google.com with SMTP id l65so5606660wmf.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 17:12:10 -0800 (PST)
In-Reply-To: <87oad0rhh8.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 4, 2016 at 4:35 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:

> Two things would be very valuable with this patchset.
>
> Some numbers on how much your changes have improved the code in the case
> you care about.  I suspect the improvements are not subtle so this
> should not be hard.
>
> Can you please provide a justification for event_list.  Just skimming
> through it appears that event_list because a duplicate of the list of
> batched network devices that are passed to dev_close_many and friends.
> If the list is actually a duplicate it appears foolish to create it.
>
> Eric

The performance test I ran tries to unregister 1000 dummy interfaces
with 512K routes in the fib.
Without the patch I could unregister 35 interfaces per second and with
the patch it jumped to 620
interfaces per second. 512K is a lot of routes but I am assuming we
would get a good improvement
even with 100K routes in the fib.

I am using event_list to put all the net namespaces in the current
net_device batch on a list and only
call the NETDEV_UNREGISTER_BATCH on those namespaces. It would be
possible to just call the
notifier for NETDEV_DOWN/UNREGISTER_BATCH for all the devices on the
list and rely on the
needs_fib_flush flag to only call fib_flush once per namespace but it
seems like a waste to me.

Salam
