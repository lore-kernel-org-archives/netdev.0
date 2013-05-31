From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/12] tipc: Add "max_ports" configuration
 parameter
Date: Fri, 31 May 2013 01:40:28 -0700 (PDT)
Message-ID: <20130531.014028.420559536226155172.davem@davemloft.net>
References: <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se>
	<20130531.012922.204204156468438634.davem@davemloft.net>
	<20130531083455.GA7568@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab3EaIk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:40:29 -0400
In-Reply-To: <20130531083455.GA7568@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>
Date: Fri, 31 May 2013 10:34:55 +0200

> On Fri, May 31, 2013 at 01:29:22AM -0700, David Miller wrote:
>> From: Erik Hugne <erik.hugne@ericsson.com>
>> Date: Fri, 31 May 2013 10:25:38 +0200
>> 
>> > On Thu, May 30, 2013 at 03:49:25PM -0700, David Miller wrote:
>> >> View compile time constants and module parameters as artificial
>> >> limits, they are terrible and unnecessary.
>> >> 
>> >> There is no reason you cannot restructure this table so that you
>> >> can dynamically size it at run time.
>> > 
>> > The TIPC ref table index is used directly as the port identity in the 
>> > TIPC publications. When a socket is bound, this ID is published to all 
>> > other nodes in the cluster.
>> > If we where to allow the table to be changed dynamically, we would need
>> > to change the port identities for already bound sockets/ports, withdraw
>> > the old identity and publish the new one.
>> 
>> No you do not, simply grow the table just like we dynamically grow
>> hash tables in response to network/socket activity elsewhere in the
>> kernel.  You'll only allocate new indexes from the newly allocated
>> area, the existing indexes will remain the same.
> 
> And if someone tries to reduce the table size?
> Should we simply disallow that?

We never shrink the hash tables once we've grown them.  That's a
reasonable way to behave.
