From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 13:50:34 -0700
Message-ID: <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	<1340823810.26242.81.camel@edumazet-glaptop>
	<4FEB6B64.5060708@hp.com>
	<1340829541.26242.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Tom Parkin <tparkin@katalix.com>,
	netdev@vger.kernel.org, David.Laight@ACULAB.COM,
	James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36332 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142Ab2F0Uuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 16:50:44 -0400
In-Reply-To: <1340829541.26242.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Jun 2012 22:39:01 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> All sane SNMP applications are ready to cope with 32bits counters
> wrapping.

Actually that statement depends on the data rate. SNMP daemons work
by polling at periodic intervals. The limit for detecting roll over depends
on the rate and the interval. I believe the ubiquitous net-snmp code uses
something a 30 second polling interval for lots of it's caches. This means
it rolls over too fast at 10G. Polling faster can help but net-snmp is
a pig about updates.

I just realized the whole x32 (running 32 bit apps on 64 bit kernel) is broken
for things like /proc/net/dev where 64 bit kernel will give 64 bit values and
the 32 bit app (like net-snmp) is expecting unsigned long (32 bits).
