From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: possible bug in latest network tree
Date: Wed, 30 Mar 2016 14:17:43 -0700
Message-ID: <1459372663.6473.211.camel@edumazet-glaptop3.roam.corp.google.com>
References: <660C7E53FDDFB64C8741117E0D659AAAB8463B9F@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Light, John J" <john.j.light@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34584 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbcC3VRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 17:17:51 -0400
Received: by mail-pa0-f53.google.com with SMTP id fe3so49594816pab.1
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 14:17:51 -0700 (PDT)
In-Reply-To: <660C7E53FDDFB64C8741117E0D659AAAB8463B9F@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-30 at 21:05 +0000, Light, John J wrote:
> David,
> 
> I see a recent change in inet_connection_sock.c that uses
> sysctl_tcp_synack_retries suspiciously.
> 
> Previously, sysctl_tcp_synack_retries was a global variable, and now
> it has been moved into the fragment (really netns_ipv4).

You mean the network namespace ?
> 
> In reqsk_timer_handler (inet_connection_sock.c) near line 563 it is
> used as the default max_retries value in case icsk->icsk_syn_retries
> is not set.
> 
> Previously, other transports (dccp?) would use the TCP global variable
> as a default.  Now that the defaults come from the fragment, I suspect
> the fragment variable is not set for other transports.  (I can't find
> where it's set for dccp.)
> 
> Of course, this will only show in non-TCP transport protocols when the
> icsk retries value is not set, so it's a rare case.  Perhaps it's an
> unreachable case, since I don't know all the kernel paths.
> 
> Maybe the problem is that the default shouldn't be to a TCP value, but
> should be a 'transport' value.
> 
> This code is somewhat convoluted, so I am not sure of my analysis, but
> I wanted you to consider it.
> 

No idea why you ask David instead of patch author ?

I don't see any problem here.

Do we really want to spend time on this minor issue ?
