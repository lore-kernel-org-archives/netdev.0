From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net: Automatic IRQ siloing for network devices
Date: Sat, 16 Apr 2011 01:50:30 +0100
Message-ID: <1302915030.5282.778.camel@localhost>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
	 <1302908069.2845.29.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11670 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515Ab1DPAud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 20:50:33 -0400
In-Reply-To: <1302908069.2845.29.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-15 at 23:54 +0100, Ben Hutchings wrote:
> On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> > Automatic IRQ siloing for network devices
> > 
> > At last years netconf:
> > http://vger.kernel.org/netconf2010.html
> > 
> > Tom Herbert gave a talk in which he outlined some of the things we can do to
> > improve scalability and througput in our network stack
> > 
> > One of the big items on the slides was the notion of siloing irqs, which is the
> > practice of setting irq affinity to a cpu or cpu set that was 'close' to the
> > process that would be consuming data.  The idea was to ensure that a hard irq
> > for a nic (and its subsequent softirq) would execute on the same cpu as the
> > process consuming the data, increasing cache hit rates and speeding up overall
> > throughput.
> > 
> > I had taken an idea away from that talk, and have finally gotten around to
> > implementing it.  One of the problems with the above approach is that its all
> > quite manual.  I.e. to properly enact this siloiong, you have to do a few things
> > by hand:
> > 
> > 1) decide which process is the heaviest user of a given rx queue 
> > 2) restrict the cpus which that task will run on
> > 3) identify the irq which the rx queue in (1) maps to
> > 4) manually set the affinity for the irq in (3) to cpus which match the cpus in
> > (2)
> [...]
> 
> This presumably works well with small numbers of flows and/or large
> numbers of queues.  You could scale it up somewhat by manipulating the
> device's flow hash indirection table, but that usually only has 128
> entries.  (Changing the indirection table is currently quite expensive,
> though that could be changed.)
[...]

Actually, I reckon you could do a more or less generic implementation of
accelerated RFS on top of a flow hash indirection table.  It would
require the drivers to provide a new function to update single table
entries, and some way to switch between automatic configuration by RFS
and manual configuration with ethtool.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

