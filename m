From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH tcp-2.6 0/2]: SACK block validation
Date: Tue, 19 Jun 2007 01:25:56 +0300
Message-ID: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33489 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762709AbXFRW0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 18:26:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

SACK block validation to tcp-2.6 tree. Before preparing this, I rebased
tcp-2.6 to net-2.6 (not 2.6.23) because of DSACK patch in net-2.6 (some
conflicts will occur). I did some very basic testing with this. No
TCPSACKDiscards occured in it but it's kind of hard for me to fully
test the whole internet without being a server end for most of it,
maybe I should start abusing all port probers for that purpose by using
them as sinks... :-)

This patchset addresses the only issue I found while trying to address
your earlier comments (found in here):
  http://marc.info/?l=linux-netdev&m=118060110632768&w=2
It's perfectly ok for timedout_continue to be NULL and it's being
checked for except when the result of find for tp->highest_sack is
accessed (that will be a valid skb because sacked_out > 0). Actually
I didn't fully understand what was the concern with timedout_continue
rather than with skb... But this problem was located anyway, so the
comment itself proved useful (and DSACK regression got fixed too due
to it :-)).

If they it looks sane, you can consider applying to tcp-2.6 (rebasing
is needed for that). I'm not entirely sure if I can add MIB stuff
just like that (couldn't find any examples from the available history)
though some info will definately be useful when trying to figure out
regression reports (due to flawed TCP implementation of the peer).
Yes, it might cause some troubles when communicating with broken TCP
implementations.

Do you have some plans regarding tcp-2.6? FYI, I've also discovered
that the current implementation of timedout_mark_forward is flawed
because "tcp_skb_timedout() boundary" is advanced whenever
retransmissions there occur but I probably don't have time to address
that until mid-July or so. I think that the hint is not coming back
though as TCP can use a binary search that finds TCBCB_TAGBITS
boundary using the RB-tree. My other plans include, e.g., combining
highest_sack(+fackets_out) and sack fastpath hints but that requires
some benchmarking first to see how frequently they are different, I
suspect it won't really happen that often, so most of the time we have
three u32s and one skb ptr "pointing" the very same place (fackets stuff
is not really pointing but related like you said earlier)... :-)

--
 i.



