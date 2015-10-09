From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [PATCH 3.19 and earlier] fib_rules: Fix dump_rules() not to exit early
Date: Fri, 09 Oct 2015 16:33:56 +0200
Message-ID: <3579656.ISPokoglEp@storm>
References: <1444066168-5566-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:48851 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854AbbJIOnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 10:43:39 -0400
In-Reply-To: <1444066168-5566-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roland,

On Monday, 5. October 2015 10:29:28 Roland Dreier wrote:
> From: Roland Dreier <roland@purestorage.com>
> 
> Backports of 41fc014332d9 ("fib_rules: fix fib rule dumps across
> multiple skbs") introduced a regression in "ip rule show" - it ends up
> dumping the first rule over and over and never exiting, because 3.19
> and earlier are missing commit 053c095a82cf ("netlink: make
> nlmsg_end() and genlmsg_end() void"), so fib_nl_fill_rule() ends up
> returning skb->len (i.e. > 0) in the success case.
> 
> Fix this by checking the return code for < 0 instead of != 0.

thanks for this fix. You just saved me an afternoon of bisecting :)

I can confirm that this fixes the mentioned issue introduced in 3.14.54.
We have an automated ipsec VPN test that failed after the upgrade:
The "ip rule list" command was hanging forever.

Cheers,
Thomas
