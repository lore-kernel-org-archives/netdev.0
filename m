From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lse-tech] Re: A common layer for Accounting packages
Date: Sun, 27 Feb 2005 23:39:43 -0800
Message-ID: <20050227233943.6cb89226.akpm@osdl.org>
References: <42168D9E.1010900@sgi.com>
	<20050218171610.757ba9c9.akpm@osdl.org>
	<421993A2.4020308@ak.jp.nec.com>
	<421B955A.9060000@sgi.com>
	<421C2B99.2040600@ak.jp.nec.com>
	<421CEC38.7010008@sgi.com>
	<421EB299.4010906@ak.jp.nec.com>
	<20050224212839.7953167c.akpm@osdl.org>
	<20050227094949.GA22439@logos.cnet>
	<4221E548.4000008@ak.jp.nec.com>
	<20050227140355.GA23055@logos.cnet>
	<42227AEA.6050002@ak.jp.nec.com>
	<1109575236.8549.14.camel@frecb000711.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaigai@ak.jp.nec.com, marcelo.tosatti@cyclades.com, davem@redhat.com,
        jlan@sgi.com, lse-tech@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        elsa-devel@lists.sourceforge.net
To: Guillaume Thouvenin <guillaume.thouvenin@bull.net>
In-Reply-To: <1109575236.8549.14.camel@frecb000711.frec.bull.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Guillaume Thouvenin <guillaume.thouvenin@bull.net> wrote:
>
>    Ok the protocol is maybe too "basic" but with this mechanism the user
>  space application that uses the fork connector can start and stop the
>  send of messages. This implementation needs somme improvements because
>  currently, if two application are using the fork connector one can
>  enable it and the other don't know if it is enable or not, but the idea
>  is here I think.

Yes.  But this problem can be solved in userspace, with a little library
function and a bit of locking.

IOW: use the library to enable/disable the fork connector rather than
directly doing syscalls.

It has the problem that if a client of that library crashes, the counter
gets out of whack, but really, it's not all _that_ important, and to handle
this properly in-kernel each client would need an open fd against some
object so we can do the close-on-exit thing properly.  You'd need to create
a separate netlink socket for the purpose.
