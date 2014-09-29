From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv8 net-next 2/4] sunvnet: make transmit path zero-copy
 in the kernel
Date: Mon, 29 Sep 2014 16:54:40 -0400 (EDT)
Message-ID: <20140929.165440.1575595209745066192.davem@davemloft.net>
References: <5429B8E2.40204@oracle.com>
	<20140929.162950.1960056644564225055.davem@davemloft.net>
	<5429C498.1000705@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	raghuram.kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbaI2Uym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:54:42 -0400
In-Reply-To: <5429C498.1000705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 16:44:08 -0400

> On 09/29/2014 04:29 PM, David Miller wrote:
> 
>> 
>> It doesn't work to liberate SKBs in the TX ring purely from the
>> ->ndo_start_xmit() method.
>> 
>> All SKBs given to a device must be liberated in a finite, short,
>> amount of time.
> 
> I did consider putting a garbage-collector via timer on them, since
> we got such a boost from not ACKing every packet. I guess the question
> is "how short?"
> 
> For example, I could leave the "normal" path like this and just start/mod
> a timer to do it after 1 sec if we haven't done it through start_xmit. Do
> you think that's sufficiently short?

To be honest I'm not %100 sure.

SKB liberation frees up space in the TCP socket send buffer, so... but
arguably if the connection actually cares and is in steady state then
we'll be liberating via the ->ndo_start_xmit() flush you do here.
