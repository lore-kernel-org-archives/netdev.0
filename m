From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Thu, 16 Dec 2004 02:32:17 +0200
Message-ID: <20041216003217.GA6058@ee.oulu.fi>
References: <41523EC5.20805@tomt.net> <41527796.4010204@tomt.net> <4152843D.6010204@tomt.net> <20040923.172253.125681726.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040923.172253.125681726.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 05:22:53PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > > If I boot with net.ipv6.conf.default.forward = 1 in sysctl.conf - but 
> > > then after the boot do echo 1 > /proc/sys/net/ipv6/conf/all/forward (to 
> > > actually get it running)
> > > I have the ipv6/conf/default/forwarding set in sysctl.conf on all the 
> > > routers, and it seems zebra sets the ipv6/conf/all/forwarding later on.
> > if default is set first, then tunnels created, followed by setting 
> > "all"; everything breaks down on ifdown.
> > 
> > pretty neat :)
> 
> Thank you everyone for tracking down this bug.
> I will fix this bug and come up with patch tomorrow (or so).
> Thanks again.
Hiya

There seems to be a regression, I've recently bumped into this bug again.
(2.6.9-fc3-latest-thing, I didn't see anything relevant in latest Linus bk).
It did work for some time ago, since them my ipv6 configuration has changed
and I've updated the kernel quite a bit.

   if [ "$device" != "sit0" ]; then
                if ipv6_exec_ip tunnel show $device 2>/dev/null | LC_ALL=C grep -q -w "ipv6/ip"; then
                        ipv6_exec_ip tunnel del $device

is what triggers it, tunnel del gets stuck with a refcnt of 1, device is no
longer in /proc/net/dev. Tunnel is run on top of PPPoE and it's a dynamic
sixxs.net aiccu thing. IPv6 forwarding is on.

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=282023 seems to be related
too.
