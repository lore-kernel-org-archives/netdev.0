From: Paul Mackerras <paulus@samba.org>
Subject: Re: Fw: [Bugme-new] [Bug 4381] New: When i try to start a pppoe conn.,
 crash at net/core/skbuff.c:91
Date: Wed, 23 Mar 2005 14:06:51 +1100
Message-ID: <16960.56651.563544.695661@cargo.ozlabs.ibm.com>
References: <20050321201150.39ba3467.akpm@osdl.org>
	<4240D266.4080403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, o.cornu@gmail.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4240D266.4080403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy writes:

> Looks like hdrlen is uninitialized in ppp_async. This patch

No, it is initialized by the memset at line 165, and 0 is the correct
value for ap->chan.hdrlen, since the ppp_async driver doesn't prepend
any bytes to the skb on transmit.  The bug must be somewhere else.  It
would be very interesting to know what value pf->hdrlen has in
ppp_write and how it got that value though.

Paul.
