From: jamal <hadi@cyberus.ca>
Subject: Re: network delay simulation
Date: 17 Mar 2004 11:09:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1079539766.1034.99.camel@jzny.localdomain>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	 <20040316174134.2f1da12a.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040316174134.2f1da12a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-03-16 at 20:41, David S. Miller wrote:
 
> > Any ideas/comments? Somebody have some code sitting in a drawer?

I had something trying to replace nistnet a while back - probably
have to go 10 harddrives back to find it.

> Probably a packet scheduler would be my first choice, you could then even
> tag packets using classification and therefore delay differently for different
> flows.

This is exactly what i had. You need to be able to choose what flow gets
affected and which ones are left alone.
A better approach is to use the action code patches i have because then
you can cascade actions that you want and keep adding new error
injection actions
example delay for random time between 30 seconds to 1 minute, then fuck
the checksum, then simulate congestion ... with each of those actions
selectable on how it gets added to the datapath.

> Another thing I've always wanted to do was add a "struct netdev *" argument
> to dev_alloc_skb(), then we could do things like do SKB allocation failure
> tests on drivers to stress them in low memory situations and weird patterns
> of alloc failures.  Probably do this in a transitional way via a new routine
> with a new name that drivers gradually move over to using.

this is valuable. I can bet you over 70% of the drivers will puke like
theres no tommorow.
Not just that, the net stack code will too.

> The idea is that we provide an interface by which to upload some bit string
> of alloc success/failure binary states, and at each alloc the state machine
> just runs through the bits to decide whether to just quickly return NULL or
> not.

A simple algorithm is random().

cheers,
jamal
