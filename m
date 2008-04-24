From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Thu, 24 Apr 2008 15:39:09 -0700
Message-ID: <1e41a3230804241539n3c0c8ab3iafedc7861947ee5@mail.gmail.com>
References: <480E8523.4030007@hp.com>
	 <1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
	 <20080422.205945.229828014.davem@davemloft.net>
	 <87ej8uyjvv.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:4827 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbYDXWjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 18:39:11 -0400
Received: by wr-out-0506.google.com with SMTP id c48so2134923wra.1
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 15:39:10 -0700 (PDT)
In-Reply-To: <87ej8uyjvv.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 3:21 PM, Andi Kleen <andi@firstfloor.org> wrote:
> David Miller <davem@davemloft.net> writes:
>
>  >> What is your interface txqueuelen and mtu?  If you have a very large
>  >> interface queue, TCP will happily fill it up unless you are using a
>  >> delay-based congestion controller.
>  >
>  > Yes, that's the fundamental problem with loss based congestion
>  > control.  If there are any queues in the path, TCP will fill them up.
>
>  That just means Linux does too much queueing by default.  Perhaps that
>  should be fixed. On Ethernet hardware the NIC TX queue should be
>  usually sufficient anyways I would guess. Do we really need the long
>  qdisc queue too?

The default on most ethernet devices used to be 100 packets.  This is
pretty short when your flow's window size is thousands of packets.
It's especially a killer for large BDP flows because it causes
slow-start to cut out early and you have to ramp up slowly with
congestion avoidance.  (This effect it mitigated somewhat by cubic,
etc, or even better by limited slow-start, but it's still very
significant.)

I have in the past used a hack that suppressed congestion notification
when overflowing the local interface queue.  This is a very simple
approach, and works fairly well, but doesn't have the property of
converging toward fairness if multiple flows are competing for
bandwidth at the local interface.  It might be possible to cook
something up that's smarter.

  -John
