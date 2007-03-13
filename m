From: Andi Kleen <andi@firstfloor.org>
Subject: Re: bridge: faster compare for link local addresses
Date: 13 Mar 2007 15:01:27 +0100
Message-ID: <p731wjt9r9k.fsf@bingen.suse.de>
References: <20070312162015.5d22cd68@dxpl.pdx.osdl.net>
	<45F5EAD3.8050501@hp.com>
	<20070312.171029.85409273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:34557 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753249AbXCMNCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 09:02:12 -0400
In-Reply-To: <20070312.171029.85409273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 12 Mar 2007 17:05:39 -0700
> 
> > Being paranoid - are there no worries about the alignment of dest?
> 
> If it's an issue, it's an issue elsewhere too, as the places
> where Stephen took this idiomatic code from is the code
> ethernet handling and that runs on every input packet via
> eth_type_trans().

As a quick note -- when you tell gcc the expected alignment
by using correct types then moderm gcc should generate fast inline code 
for memcpy/memcmp/etc. by itself. It only falls back to a slow generic
function when it cannot figure out the alignment or the size.

So I expect just using u32 * instead of char * should have the same
effect and would be somewhat cleaner and the memcmp could be kept.

-Andi
