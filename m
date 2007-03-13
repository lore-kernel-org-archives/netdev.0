From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: bridge: faster compare for link local addresses
Date: Tue, 13 Mar 2007 13:06:54 -0700
Message-ID: <20070313130654.7addde2b@freekitty>
References: <20070312.171029.85409273.davem@davemloft.net>
	<p731wjt9r9k.fsf@bingen.suse.de>
	<200703131438.32570.dada1@cosmosbay.com>
	<20070313.123954.21595557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, andi@firstfloor.org, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:32909 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933112AbXCMUHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 16:07:31 -0400
In-Reply-To: <20070313.123954.21595557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Mar 2007 12:39:54 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 13 Mar 2007 14:38:32 +0100
> 
> > But memcmp() has a strong semantic (in libc). memcmp(a, b, 6) should
> > do 6 byte compares and conditional branches, regardless of a/b
> > alignment.  Or use the x86 "rep cmpsb" instruction that basically
> > has the same cost.
> 
> Yep, that's the issue, gcc won't make the reductions necessary
> here to get it down to one comparison and one branch.

Also, for our usage we only care about equality, not greater/less than
return value.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
