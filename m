From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] can't unload network device's if IPV6 is loaded
Date: Fri, 12 Dec 2003 22:59:36 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1AUlxI-00060F-00@gondolin.me.apana.org.au>
References: <20031211153334.0c59214b.shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org (Stephen Hemminger), netdev@oss.sgi.com
In-Reply-To: <20031211153334.0c59214b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> In 2.6.0-test11, IPV6 is not correctly cleaning up the network device reference's
> (ie missing dev_put).  So if I do:
>        rmmod e100
> it hangs forever and complains about that not all references have been cleaned up.
> 
> This happens even if no IPV6 addresses have been set up. Just having ipv6 available
> to be loaded at boot up.  The vendor startup scripts (SuSe 9) may be setting something.

I can't reproduce this here.  I've done

modprobe dummy
ifconfig dummy0 up
modprobe ipv6
ifconfig dummy0 down
rmmod dummy

It does complain that there are 3 remaining references to dummy0, but
they go away after a few seconds and the module unloads.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
