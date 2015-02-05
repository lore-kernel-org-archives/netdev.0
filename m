From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: group DCTCP socket statistics
Date: Thu, 5 Feb 2015 10:44:23 -0800
Message-ID: <20150205104423.18b0b59b@urahara>
References: <1422310659-9357-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:45078 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbBESou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:44:50 -0500
Received: by pdbnh10 with SMTP id nh10so6766735pdb.12
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:44:49 -0800 (PST)
In-Reply-To: <1422310659-9357-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Jan 2015 23:17:39 +0100
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> Keep ss output consistent and format DCTCP socket statistics similar to skmen
> and timer where a group of logical values are grouped by brackets. This makes
> parser scripts *and* humans more happy.
> 
> 
> Current output of 'ss -inetm dst :80':
> ESTAB       0      0 192.168.11.14:55511 173.194.66.189:443
> 	timer:(keepalive,14sec,0) uid:1000 ino:428768
> 	sk:ffff88020ceb5b00 <-> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
> 	ts sack wscale:7,7 rto:250 rtt:49.225/20.837 ato:40 mss:1408 cwnd:10
> 	ce_state 23 alpha 23 ab_ecn 23 ab_tot 23 send 2.3Mbps
> 	lastsnd:121026 lastrcv:121026 lastack:30850 pacing_rate 4.6Mbps
> 	retrans:0/2 rcv_rtt:40.416 rcv_space:2920
> 
> New grouped output:
> ESTAB       0      0 192.168.11.14:55511 173.194.66.189:443
> 	timer:(keepalive,14sec,0) uid:1000 ino:428768
> 	sk:ffff88020ceb5b00 <-> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
> 	ts sack wscale:7,7 rto:250 rtt:49.225/20.837 ato:40 mss:1408 cwnd:10
> 	dctcp(ce_state:23,alpha:23,ab_ecn:23,ab_tot:23) send 2.3Mbps
> 	lastsnd:121026 lastrcv:121026 lastack:30850 pacing_rate 4.6Mbps
> 	retrans:0/2 rcv_rtt:40.416 rcv_space:2920
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  misc/ss.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 

The patch looks fine, although changing output formats is normally not good
because someone might be scripting from this. But DCTCP is so new I am
willing to allow the change.

The problem is that the patch does not apply to either the master
(or net-next) branchs of upstream source.

Please fix that and resubmit.
