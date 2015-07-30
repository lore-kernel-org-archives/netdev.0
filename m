From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix sockopt size check
Date: Thu, 30 Jul 2015 09:00:25 -0300
Message-ID: <20150730120025.GB2456@localhost.localdomain>
References: <387de09215f2ad50481516932f213cccfa077e3e.1438092726.git.marcelo.leitner@gmail.com>
 <20150729.170731.1725393558438186362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbbG3MAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2015 08:00:31 -0400
Content-Disposition: inline
In-Reply-To: <20150729.170731.1725393558438186362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 05:07:31PM -0700, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Tue, 28 Jul 2015 11:16:23 -0300
> 
> > The problem is not on being bigger than what we want, but on being
> > smaller, as it causes read of invalid memory.
> > 
> > Note that the struct changes on commit 7e8616d8e773 didn't affect
> > sctp_setsockopt_events one but that's where this check was flipped.
> > 
> > Fixes: 7e8616d8e773 ("[SCTP]: Update AUTH structures to match
> > declarations in draft-16.")
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> This makes things worse.
> 
> The copy_from_user() call is bounded by optlen, so if you allow it to
> be any arbitrary large value the user can write past the end of the
> structure, corrupting kernel memory.

Indeed. I should have changed copy_from_user() to copy the size of the
struct too. But then the issue I thought there was, there isn't and it
just allows partial updates, as it won't read any further than optlen.

> No, the test is correct, or at least necessary, as-is.

Yes. Please drop this. Thanks.

  Marcelo
