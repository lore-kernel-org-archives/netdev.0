From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Thu, 16 Jun 2016 17:26:32 -0700 (PDT)
Message-ID: <20160616.172632.1759391103978744570.davem@davemloft.net>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbcFQA0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 20:26:34 -0400
In-Reply-To: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 16 Jun 2016 10:37:13 +0200

> Until now we had stats functions return SW statistics. However, it makes
> a lot of sense to return HW stats as default. The existing apps count with
> having the defaults stats complete, but that is not true now as the offloaded
> forward traffic is not visible there.
> 
> If user wants to know real SW stats, this patchset provides way to get
> it as well.

I think we haven't been very good about defining good rules nor
guidelines for how to handle HW vs SW stats, and I'm talking
strictly about what we publish via rtnl_link_stats64.

However, if I were working from scratch on a new driver what I would
be inclined to do is use HW stats for everything that the chip
provides direct and accurate support for, and fill in the gaps with SW
stats.

Because to me, stats are stats, the user wants to know (for example)
how many broadcast packets have gone through the port and doesn't care
how you obtain that number.

If the problem being addressed is that drivers aren't reporting
information on all the packets going through the device, then that's a
bug.

But it seems to me like mlxsw is already maintaining the software
statistic counters, so I can't see a performance reason for not
properly providing all of the statistics using HW vs. SW as is
appropriate for each and every value to fix this problem.  Why
create an entire new facility just for that?  It doesn't seem to
be needed.

Maybe you just need to describe things a bit more completely in this
header posting.
