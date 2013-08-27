From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-08-25
Date: Tue, 27 Aug 2013 12:37:18 -0400 (EDT)
Message-ID: <20130827.123718.732194018797657395.davem@davemloft.net>
References: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
	<20130827.121826.532177208564127527.davem@davemloft.net>
	<1377620768.13272.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab3H0QhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 12:37:21 -0400
In-Reply-To: <1377620768.13272.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 27 Aug 2013 17:26:08 +0100

> On Tue, 2013-08-27 at 12:18 -0400, David Miller wrote:
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> Date: Sun, 25 Aug 2013 23:56:03 +0100
>> 
>> > The following changes since commit f073dde03b3e8d11050d82f52caaf75fd924e069:
>> > 
>> >   sfc: Make efx_mcdi_init() call efx_mcdi_handle_assertion() (2013-08-21 19:43:09 +0100)
>> > 
>> > are available in the git repository at:
>> > 
>> >   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
>> > 
>> > for you to fetch changes up to f76fe120d81c96fa2a17ae41f0647c963dbb43cd:
>> > 
>> >   sfc: Update and improve kernel-doc for efx_mcdi_state & efx_mcdi_iface (2013-08-21 20:20:41 +0100)
>> > 
>> > 1. Refactoring and cleanup in preparation for new hardware support.
>> > 2. Some bug fixes for firmware completion handling.  (They're not known
>> > to cause real problems, otherwise I'd be submitting these for net and
>> > stable.)
>> > 3. Update to the firmware protocol (MCDI) definitions.
>> 
>> Pulled, but I want to point out an existing issue which is that using
>> an atomic_t for mcdi->state is bogus.  You're only using atomic_set()
>> and atomic_read() on the value, and that provides no "atomicity" per-se.
> 
> Thanks.  I don't know what you looked for, but there are actually two
> atomic_cmpxchg() calls in mcdi.c.

I still think atomic_t is not appropriate, you can use plain xchg() as we
do all over the IPV4 stack, such as in the TCP metrics cache and the
routing code.

Really, if I don't see an atomic_*_and_test() or similar kind of
operation being used, I really don't want to see an atomic_t type in
use.
