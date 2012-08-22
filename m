From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding: time limits too tight in bond_ab_arp_inspect
Date: Wed, 22 Aug 2012 11:54:13 -0600
Message-ID: <50351CC5.3030109@genband.com>
References: <20120822174534.GA20260@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Petr Tesarik <ptesarik@suse.cz>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og117.obsmtp.com ([64.18.2.6]:54057 "EHLO
	exprod7og117.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026Ab2HVRy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 13:54:58 -0400
In-Reply-To: <20120822174534.GA20260@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 11:45 AM, Jiri Bohac wrote:

> This code is run from bond_activebackup_arp_mon() about
> delta_in_ticks jiffies after the previous ARP probe has been
> sent. If the delayed work gets executed exactly in delta_in_ticks
> jiffies, there is a chance the slave will be brought up.  If the
> delayed work runs one jiffy later, the slave will stay down.

<snip>

> Should they perhaps all be increased by, say, delta_in_ticks/2, to make this
> less dependent on the current scheduling latencies?

We have been using a patch that tracks the arpmon requested sleep time 
vs the actual sleep time and adds any scheduling latency to the allowed 
delta.  That way if we sleep too long due to scheduling latency it 
doesn't affect the calculation.

Chris
