From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: Link detection
Date: Mon, 14 Mar 2005 16:05:02 +0200
Message-ID: <200503141605.02959.hasso@estpak.ee>
References: <200503141435.38227.hasso@estpak.ee> <20050314133216.GM31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050314133216.GM31837@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> The routes must stay if the interface isn't shut down completely. A loss
> of the carrier can be temporarly for just a very short period of time.
> What we can do is, like in the neighbour tables, differ between a
> adimistrative shutdown and a loss of the carrier with a new flag, would
> that help you?

In theory yes, if this info is carried over netlink. 

> Problem #1: Differ between a temporary loss of carrier and a permanent
>             failure. Relatively easy from userspace because userspace
>      knows about the strategy.

Is there need for that? There should be knob of course to tune behaviour 
IMHO. Sure there are applications which expect current behaviour. 

> Problem #2: Strategy upon resume of carrier signal, userspace can simply
>             reread its configuration and add the routes again. Kernel
>      must backup them and somehow ensure that they stay
>      consistent. Imagine you delete a route to a certain host but
>      one of your links is down at the moment, the route will be
>      restored once the interface comes back up which is probably
>      unexpected behaviour.

I think that you misunderstood. I don't talk about any routes created by any 
user space applications or by user. These _must_ be untouched of course. 
I'm talking about routes _kernel_ creates if address is added to the 
interface. All other routes are not problem anyway. Even if their next hop 
points to network behind down interface, their next hop is unreachable and 
route shouldn't be used, no?

arena:/home/hasso# ip route | grep 192.168
arena:/home/hasso# ip addr add 192.168.1.1/24 dev eth0
arena:/home/hasso# ip route | grep 192.168
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.1
arena:/home/hasso#

I'm talking only about these routes - created by kernel with link scope.


with my best wishes,

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
