From: David Miller <davem@davemloft.net>
Subject: Re: bridge: faster compare for link local addresses
Date: Tue, 13 Mar 2007 12:39:54 -0700 (PDT)
Message-ID: <20070313.123954.21595557.davem@davemloft.net>
References: <20070312.171029.85409273.davem@davemloft.net>
	<p731wjt9r9k.fsf@bingen.suse.de>
	<200703131438.32570.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933535AbXCMTkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 15:40:04 -0400
In-Reply-To: <200703131438.32570.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 13 Mar 2007 14:38:32 +0100

> But memcmp() has a strong semantic (in libc). memcmp(a, b, 6) should
> do 6 byte compares and conditional branches, regardless of a/b
> alignment.  Or use the x86 "rep cmpsb" instruction that basically
> has the same cost.

Yep, that's the issue, gcc won't make the reductions necessary
here to get it down to one comparison and one branch.
