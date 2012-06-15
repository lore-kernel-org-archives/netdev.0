From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash
 via /proc/net/ipv6_route
Date: Fri, 15 Jun 2012 15:32:40 -0700 (PDT)
Message-ID: <20120615.153240.1699971156820399680.davem@davemloft.net>
References: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
	<20120615105655.GA22945@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758316Ab2FOWcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 18:32:41 -0400
In-Reply-To: <20120615105655.GA22945@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 15 Jun 2012 06:56:55 -0400

> On Fri, Jun 15, 2012 at 11:00:17AM +0200, Thomas Graf wrote:
>> /proc/net/ipv6_route reflects the contents of fib_table_hash. The proc
>> handler is installed in ip6_route_net_init() whereas fib_table_hash is
>> allocated in fib6_net_init() _after_ the proc handler has been installed.
>> 
>> This opens up a short time frame to access fib_table_hash with its pants
>> down.
>> 
>> fib6_init() as a whole can't be moved to an earlier position as it also
>> registers the rtnetlink message handlers which should be registered at
>> the end. Therefore split it into fib6_init() which is run early and
>> fib6_init_late() to register the rtnetlink message handlers.
>> 
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Reviewed-by: Neil Horman <nhorman@tuxdriver.com>

Applied.

Since you're snooping around in here, you might notice that on network
namespace shutdown, we leak all user configured ipv6 FIB rules.
