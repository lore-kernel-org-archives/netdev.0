From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Tue, 16 Nov 2004 10:47:55 -0800
Message-ID: <20041116104755.32bdb7a7.davem@davemloft.net>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Nov 2004 09:47:14 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> We are seeing following assertions when running specweb99 with
> tcp_tso_win_divisor lowered to 4, 2 or 1 on linux 2.6.9 based kernels.
> 
> KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
> KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (152)
> 
> looks like an issue with the accounting of sk_forward_alloc with non-default
> values of tcp_tso_win_divisor.

The issue is if you change the value while there are still existing
sockets which used a previous value at least once.

Looks like we'll have to cache this inside of the per-socket structure
to fix this bug, but realize that once I do that the new sysctl value
will not apply to any existing TCP sockets and this will effect your
testing.  So for example, if the web server was started with one particular
value of the sysctl, no matter how many times you change the sysctl after-
wards, the old original sysctl value will be used for every web server
connection made to the machine.
