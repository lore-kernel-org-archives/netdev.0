From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Fri, 17 Sep 2004 17:06:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917170607.2e96b58a.davem@davemloft.net>
References: <E1C8I2m-0005BS-00@gondolin.me.apana.org.au>
	<20040917.231127.114842301.yoshfuji@linux-ipv6.org>
	<20040917153536.6acec52e.davem@davemloft.net>
	<20040918.085003.77842779.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040918.085003.77842779.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Sep 2004 08:50:03 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

>  2. David's one
>     - maintenancability will be improved
>     - maintains exported symbols for binary-only modules.
>     - more function call and more stack usage.

Compiler is smarter than you think :-)

The whole stack frame is eliminated, because gcc
optimizes it away using tail-call optimizations.

Look at the assembler output for
net/ipv4/route.c:ip_route_output_key() after applying
my changes.

On sparc64 it looks like this:

ip_route_output_key:
	mov	0, %o2
	mov	0, %o3
	or	%o7, %g0, %g1
	call	ip_route_output_flow, 0
	 or	%g1, %g0, %o7

No stack frame allocated at all, it basically amounts to
a branch and clearing two argument registers.
