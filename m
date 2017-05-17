From: David Miller <davem@davemloft.net>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Wed, 17 May 2017 11:39:48 -0400 (EDT)
Message-ID: <20170517.113948.1940714175629191091.davem@davemloft.net>
References: <MWHPR1201MB01730F7F4A6BE57ADFB92EAFCAE60@MWHPR1201MB0173.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mulmer@cradlepoint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbdEQPjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:39:51 -0400
In-Reply-To: <MWHPR1201MB01730F7F4A6BE57ADFB92EAFCAE60@MWHPR1201MB0173.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Ulmer <mulmer@cradlepoint.com>
Date: Tue, 16 May 2017 15:37:39 +0000

> Blast from the past. 10 years back Wei Dong submitted the patch found (amongst several places) here:
> http://lists.openwall.net/netdev/2007/01/30/20
> 
> Problem:
> I have a firewall rule that DNATs ipv6 traffic from a destination address to ::1. The route lookup gives me the Main table & forwards that DNAT'd traffic instead of sending it to local process.
> 
> Example:
> Looking at this from a netfilter point of view, a client (IP of fd00::5) requests a web page at [2000::25:0:0:1]:8080. The firewall rule DNATs it to ::1 (note that I threw a -j TRACE in raw's REROUTING).
> TRACE: nat:PREROUTING:rule:2 SRC=fd00::5 DST=2000::25:0:0:1
> TRACE: mangle:FORWARD:rule:1 SRC=fd00::5 DST=::1
> 
> The patch is verbatim (as is the subject line for this
> email). Traffic DNAT'd to ::1 now goes to mangle's INPUT chain after
> routing decision. I'm not sure why it was removed--I'm assuming it
> was an accident--as I can't find a record in the mailing list
> archive.

It's not by accident, he received feedback from Yoshifuji and suggested
alternative ways to fix his problem:

http://marc.info/?l=linux-netdev&m=117020569620697&w=2

In fact, Yoshifuji stated that some of the behaviors are indeed
intentional.
