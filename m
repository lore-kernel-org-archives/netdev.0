From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix sockopt size check
Date: Wed, 29 Jul 2015 17:07:31 -0700 (PDT)
Message-ID: <20150729.170731.1725393558438186362.davem@davemloft.net>
References: <387de09215f2ad50481516932f213cccfa077e3e.1438092726.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbG3AHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:07:32 -0400
In-Reply-To: <387de09215f2ad50481516932f213cccfa077e3e.1438092726.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue, 28 Jul 2015 11:16:23 -0300

> The problem is not on being bigger than what we want, but on being
> smaller, as it causes read of invalid memory.
> 
> Note that the struct changes on commit 7e8616d8e773 didn't affect
> sctp_setsockopt_events one but that's where this check was flipped.
> 
> Fixes: 7e8616d8e773 ("[SCTP]: Update AUTH structures to match
> declarations in draft-16.")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

This makes things worse.

The copy_from_user() call is bounded by optlen, so if you allow it to
be any arbitrary large value the user can write past the end of the
structure, corrupting kernel memory.

No, the test is correct, or at least necessary, as-is.
