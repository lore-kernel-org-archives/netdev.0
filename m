From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking
 functions
Date: Wed, 7 Mar 2007 19:48:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703071146091.25669@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
 <20070306194259.GK25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48280 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422797AbXCGRsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 12:48:52 -0500
In-Reply-To: <20070306194259.GK25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Baruch Even wrote:

> [snip]
> 
> > +		newtp->highest_sack = treq->snt_isn + 1;
> 
> That's the only initialization that you have for highest_sack, I think
> that you should initialize it when a loss is detected to the start_seq
> of the first packet that wasn't acked.

I agree that this problem exists and in fact I was aware of it, wasn't
just too keen to solve that yet. However, I'm not sure if the proposed
solution is adequate solution because the last ACK doesn't necessarily
contain the all-time highest SACK block (e.g., duplicate ACK reordering),
this is only remotely possible to cause entry to recovery but
still. Obviously the recovery cannot (then) be triggered with this:

	/* Not-A-Trick#2 : Classic rule... */
        if (tcp_fackets_out(tp) > tp->reordering)
                return 1;

(would have entered recovery using an earlier ACK that had the highest 
SACK block) but there are other conditions in tcp_time_to_recover as
well. I would just keep it in sync whole the time when using slowpath of 
tcp_ack. Will repost soon it and a bugfixed scoreboard thingie as 
separated patches (against the current net-2.6.22 + those two patches I 
list below, which were mentioned in the patch description btw).

> Didn't review the rest, still need to arrange a proper tree with
> preliminary patches to apply it on. Could you note the kernel you based
> it on and include all patches applied before it?

I had these patches from David Miller (posted to netdev couple of days / 
week ago in four patch serie) on the top of it:
  [TCP]: Abstract out all write queue operations.
  [TCP]: Store retransmit queue packets in RB tree.

...as I warned earlier, the rest in the David patch series probably 
conflict (at least linux/tcp.h I think because of hint removals).


-- 
 i.
