From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Fri, 17 Sep 2004 21:37:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9e473391040917183726113e91@mail.gmail.com>
References: <9e47339104091717215e9be08b@mail.gmail.com>
	 <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
Reply-To: Jon Smirl <jonsmirl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, david@gibson.dropbear.id.au, akpm@osdl.org,
        trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Call stack at failure:
e1000_exit_module
...pci calls...
e1000_remove
unregister_netdev
unregister_netdevice
notifier_call_chain
fib_netdev_event
fib_disable_ip
error_code

Rest of the info has scrolled off the screen.

The problem is when RH/Fedora is doing it's modprobe/rmmod to detect
what hardware is in the system since that's the only thing that would
be rmmod'ing e1000.

On the same system if I disable networking and boot, I can
modprobe/rmmod the drivers without problem. So I'd conclude that RH is
doing something special during it's probing phase, but I don't know
enough about the RH init scripts to know what it is.


On Sat, 18 Sep 2004 10:27:47 +1000, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> Jon Smirl <jonsmirl@gmail.com> wrote:
> > I'm still OOPsing at boot in fib_disable_ip+21 from
> > fib_netdev_event+63. Both e1000 and tg3 are effected. I have current
> > linus bk as of time of this message.
> 
> Please post the complete error message.
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 



-- 
Jon Smirl
jonsmirl@gmail.com
