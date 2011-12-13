From: Michal Soltys <soltys@ziu.info>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Wed, 14 Dec 2011 00:46:44 +0100
Message-ID: <4EE7E3E4.6070409@ziu.info>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>  <4EE358A4.7060302@ziu.info>  <1323531352.3159.106.camel@denise.theartistscloset.com>  <4EE39D88.9010002@ziu.info> <1323542103.3159.148.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1814 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909Ab1LMXqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Dec 2011 18:46:36 -0500
In-Reply-To: <1323542103.3159.148.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.12.2011 19:35, John A. Sullivan III wrote:
> On Sat, 2011-12-10 at 18:57 +0100, Michal Soltys wrote: <snip> So,
> again, trying to wear the eminently practical hat of a sys admin, for
> periodic traffic, i.e., protocols like VoiP and video that are sending
> packets are regular intervals and thus likely to reset the curve after
> each packet, m1 helps reduce latency while m2 is a way of reducing the
> chance of overrunning the circuit under heavy load, i.e., where the
> concave queue is backlogged.
>

Well, updated, - not "reset". The latter [kind of] implies the return to
original form, and just so we're on the same page - the curve would have
to be completely under the old one for that to happen. There's also no
chance of overloading anything - except if a machine is shaping on
behalf of something upstream with smaller uplink, and doing so without
UL keeping LS in check.

> When we start multiplexing streams of periodic traffic, we are still
> fine as long as we are not backlogged.  Once we are backlogged, we
> drop down to the m2 curve which prevents us from overrunning the
> circuit (assuming the sum of our rt m2 curves<= circuit size) and
> hopefully still provides adequate latency.  If we are badly
> backlogged, we have a problem with which HFSC can't help us :) (and I
> suppose where short queues are helpful).
>

Keep in mind that not backlogged classes are not hurt by backlogged
ones. And you can't overrun - be it m1 or m2, or at which point any
class activates (providing curves make sense). If everything is
backlogged, you still get nicely multiplexed traffic as defined by
your hierarchy.

If anything briefly stops being backlogged, it will get bonus on next
backlog period - while making sure, it wouldn't go with new curve above
previous backlog period's one (and assuming its actual rate is not above
the defined RT curve, as in such case it will get bonus from excess
bandwidth available as specified by LS (or will get none, if LS is not
defined)).

> If you have a chance, could you look at the email I sent entitled "An
> error in my HFSC sysadmin documentation".  That's the last piece I
> need to fall in place before I can share my documentation of this
> week's research.  Thanks - John

Yes, will do.

Btw, have you check the manpages of recent iproute2 w.r.t. hfsc ?
Lots of this should be explained, or at least mentioned there.
