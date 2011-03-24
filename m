From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Need a special way tune TCP IPv6->IPv4 fallback timeout
Date: Thu, 24 Mar 2011 09:57:02 -0700
Message-ID: <20110324095702.6f6bade0@nehalam>
References: <AANLkTikP7AFMnQ4BdnE2272zNupv_ysb3BDWTqy=9s34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Guillaume Leclanche <guillaume@leclanche.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44574 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724Ab1CXQ5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 12:57:08 -0400
In-Reply-To: <AANLkTikP7AFMnQ4BdnE2272zNupv_ysb3BDWTqy=9s34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2011 17:23:15 +0100
Guillaume Leclanche <guillaume@leclanche.net> wrote:

> Hi,
> 
> (this is a copy of text I've put in
> https://bugzilla.kernel.org/show_bug.cgi?id=23242 for anyone who would
> like to do something with bugzilla).
> 
> When applications call the connect() API, if AAAA record is returned
> and correct routing is present, the system will start a TCP connection
> over IPv6.
> However, if the host is finally unreachable, the system waits until
> the IPv6 TCP connection attempt fails, that is roughly 3 min (5
> retries, backoff, well, you know that). Then it falls back to IPv4.
> 
> Afaik, the only way to tune this timeout of 3 mins in the kernel is
> the tcp_syn_retries sysctl (RTO tuning not available in Linux TCP). By
> setting the value to 2, you can reduce the delay to ~10s which is more
> acceptable, and still 3 SYN are sent.
> 
> In order not to modify uselessly the TCP parameters for standard
> IPv4-only connections at the same time, it would be necessary to have
> a *separate* parameter-set to decrease the v6->v4 fallback delay.
> 
> No idea how feasible this is, nor if it has already been discussed
> here in the past.
> 
> // Not subscribed, please CC me.
> 
> Best regards,
> Guillaume

The best way is to try both at the same time. This trick is known
as "Happy Eyeballs"

  http://tools.ietf.org/html/draft-wing-v6ops-happy-eyeballs-ipv6-01
