From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Wed, 9 Mar 2011 07:53:19 +0100
Message-ID: <20110309065319.GA23740@xanadu.blop.info>
References: <il4vur$3ka$1@dough.gmane.org>
 <20110308111011.GA27967@xanadu.blop.info>
 <4D764AAC.30302@ncsu.edu>
 <20110308.114346.48506864.davem@davemloft.net>
 <20110308152103.714f5f05@nehalam>
 <4D76D851.4050600@ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, sangtae.ha@gmail.com
To: Injong Rhee <rhee@ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:38962 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab1CIGwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 01:52:31 -0500
Content-Disposition: inline
In-Reply-To: <4D76D851.4050600@ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/11 at 20:30 -0500, Injong Rhee wrote:
> Now, both tools can be wrong. But that is not catastrophic since
> congestion avoidance can kick in to save the day. In a pipe where no
> other flows are competing, then exiting slow start too early can
> slow things down as the window can be still too small. But that is
> in fact when delays are most reliable. So those tests that say bad
> performance with hystart are in fact, where hystart is supposed to
> perform well.

Hi,

In my setup, there is no congestion at all (except the buffer bloat).
Without Hystart, transferring 8 Gb of data takes 9s, with CUBIC exiting
slow start at ~2000 packets.
With Hystart, transferring 8 Gb of data takes 19s, with CUBIC exiting
slow start at ~20 packets.
I don't think that this is "hystart performing well". We could just as
well remove slow start completely, and only do congestion avoidance,
then.

While I see the value in Hystart, it's clear that there are some flaws
in the current implementation. It probably makes sense to disable
hystart by default until those problems are fixed.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
