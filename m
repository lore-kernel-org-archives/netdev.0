From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [patch] add iocb to network protocols
Date: Thu, 10 Oct 2002 19:40:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010194025.B13432@redhat.com>
References: <20021010183528.A13432@redhat.com> <20021010.162240.102769920.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20021010.162240.102769920.davem@redhat.com>; from davem@redhat.com on Thu, Oct 10, 2002 at 04:22:40PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2002 at 04:22:40PM -0700, David S. Miller wrote:
> 
> +#include <net/scm.h>	/* for sock_iocb */
> 
> What is this?

The private area of an iocb for network operations contains a struct 
scm_cookie.  The alternative is to allocate it via kmalloc when needed, 
but there isn't currently a way of identifying which network protocols 
require the scm_cookie.  Since most network protocols do not use it, 
would you rather remove the scm_cookie out of the default path and 
allow the protocol to choose to create it?  That would remove the 
dependancy on scm_cookie from sock_iocb entirely.

		-ben
-- 
"Do you seek knowledge in time travel?"
