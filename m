From: "David S. Miller" <davem@redhat.com>
Subject: Re: network delay simulation
Date: Tue, 16 Mar 2004 17:41:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316174134.2f1da12a.davem@redhat.com>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Mar 2004 15:10:58 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Probably "the cowboy way" would be to right a new net/scheduler to just
> do FIFO delay.
> 
> Any ideas/comments? Somebody have some code sitting in a drawer?

Probably a packet scheduler would be my first choice, you could then even
tag packets using classification and therefore delay differently for different
flows.

Another thing I've always wanted to do was add a "struct netdev *" argument
to dev_alloc_skb(), then we could do things like do SKB allocation failure
tests on drivers to stress them in low memory situations and weird patterns
of alloc failures.  Probably do this in a transitional way via a new routine
with a new name that drivers gradually move over to using.

The idea is that we provide an interface by which to upload some bit string
of alloc success/failure binary states, and at each alloc the state machine
just runs through the bits to decide whether to just quickly return NULL or
not.
