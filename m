From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 08/23] e1000: add multicast stats counters
Date: Wed, 20 Sep 2006 20:47:21 -0400
Message-ID: <4511E119.3080302@pobox.com>
References: <F2C59D1E488E7A4FB7F6F673DAF8325901C7BBF3@orsmsx413.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12933 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750873AbWIUArY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 20:47:24 -0400
To: cramerj <cramerj@intel.com>
In-Reply-To: <F2C59D1E488E7A4FB7F6F673DAF8325901C7BBF3@orsmsx413.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cramerj wrote:
>> Williams, Mitch A wrote:
>>>>> +	{ "rx_broadcast", E1000_STAT(stats.bprc) },
>>>>> +	{ "tx_broadcast", E1000_STAT(stats.bptc) },
>>>>> +	{ "rx_multicast", E1000_STAT(stats.mprc) },
>>>>> +	{ "tx_multicast", E1000_STAT(stats.mptc) },
>>>>>  	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
>>>>>  	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
>>>>>  	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
>>>> NAK -- you also need to remove the standard net stats, which are
>>>> exported elsewhere
>>> Jeff, can you please explain the reason for this NAK a little more?
>>> Neither Auke nor I understand why you rejected the patch.

>>> This patch just adds the display of a few more stats in Ethtool.  It
>>> doesn't affect any other counters, and is really just a convenience
>>> feature.  I added this to the driver because of a customer request.
>> Adding those stats is fine.  You guys just need to remove the existing
>> mess first.

> Since we have 1-to-1 mapping of some of our statistics registers to the
> net_stats, we could s/net_stats/stats/.  However, there are a few
> net_stats (e.g. net_stats.rx_errors) that encapsulate more than one
> e1000 statistic register of which we don't have a private stat member
> defined.
> 
> For those statistics, is it really necessary to add another stat
> structure just to rm "net_stats" from that list we pass to ethtool?  At
> best, it would look something like this...
> 
>   { "foo_count", E1000_STAT(stats.foo) },
> - { "rx_errors", E1000_STAT(net_stats.rx_errors) },
> + { "rx_errors", E1000_STAT(eth_stats.rx_errors) },
>   { "bar_count", E1000_STAT(stats.bar) },
> 
> If so, well, OK.  I'm just scratching my head as to why it's a "mess"
> as-is.

The ethtool get-stats sub ioctl has _always_ been for exporting _only_ 
NIC-private statistics.

So, no, there is no inherent connection between adding multicast stats 
and removing ones that should have never been in the list.  But if I 
don't put my foot down, this will never get corrected.

	Jeff


