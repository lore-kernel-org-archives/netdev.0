From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Wed, 11 Nov 2015 09:05:45 -0800
Message-ID: <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	<877fnc7i0i.fsf@bytheb.org>
	<CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
	<1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
	<1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34306 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbbKKRFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 12:05:46 -0500
Received: by igvg19 with SMTP id g19so74425610igv.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 09:05:46 -0800 (PST)
In-Reply-To: <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015 at 10:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-11-10 at 21:41 -0800, Tom Herbert wrote:
>> Tolga, are you still planning to respin this patch (when tree opens?)
>
> I was planning to add an union on skc_tx_queue_mapping and
> sk_max_ack_backlog, so that adding a check on sk_max_ack_backlog in
> listener lookup would not add an additional cache line miss.
>
> This would remove false sharing because sk_ack_backlog is often dirtied
> when a socket is added into accept queue.
>
That's sounds like good fixes, but my question was more about the
problem originally described by Tolga where we are transitioning
processing for a listener port from one process to another. I think
the conclusion in this thread was to modify the code so that
listen(fd, 0) would stop new connections from being assigned to a
socket (as opposed to explicit SO_REUSEPORT_LISTEN_OFF option). Does
this still seem reasonable?

Tom

>
>
