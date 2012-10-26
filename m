From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Fri, 26 Oct 2012 09:28:58 -0400
Message-ID: <20121026132858.GB25087@hmsreliant.think-freely.org>
References: <1351198075-20385-1-git-send-email-nhorman@tuxdriver.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B706F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52752 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758823Ab2JZN3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 09:29:08 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B706F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 26, 2012 at 10:00:13AM +0100, David Laight wrote:
> > Subject: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
> ...
> > +#define SCTP_NULL_BYTE 0xAA
> >  static inline sctp_arg_t SCTP_NULL(void)
> >  {
> > -	sctp_arg_t retval; retval.ptr = NULL; return retval;
> > +	sctp_arg_t retval;
> > +	memset(&retval, SCTP_NULL_BYTE, sizeof(sctp_arg_t));
> > +	return retval;
> >  }
> 
> You really don't want to be taking the address of a local
> variable that would normally be held in a register.
> It stops the compiler doing a lot of optimisations.
> In this case the structure is also being returned by value,
> not nice except that all(?) modern ABI do pass small structures
> in registers.
> 
Thank you dave, I hadn't considered the implications of missed optimizations
when storing to a register here.

> An assignment of some member of the union to NULL would
> seem most appropriate.
> OTOH the code that uses this must be someones 'bright idea (tm)'
> that probably wasn't such a good idea after all.
> 
nobody uses it currently, Its just that some state machine side effects don't
require an argument, but you still have to pass one in, so I was trying to
enhance this to make it obvious in a backtrace should someone inadvertently use
it in the future.  I'm going to revert it though, a big fat zero is probably
just as clear.
Neil

> 	David
> 
> 
> 
> 
