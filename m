From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Thu, 23 Sep 2004 17:22:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923.172253.125681726.yoshfuji@linux-ipv6.org>
References: <41523EC5.20805@tomt.net>
	<41527796.4010204@tomt.net>
	<4152843D.6010204@tomt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: andre@tomt.net, tgraf@suug.ch, pp@ee.oulu.fi, jgarzik@pobox.com,
        dwmw2@infradead.org
In-Reply-To: <4152843D.6010204@tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4152843D.6010204@tomt.net> (at Thu, 23 Sep 2004 10:07:25 +0200), Andre Tomt <andre@tomt.net> says:

> > If I boot with net.ipv6.conf.default.forward = 1 in sysctl.conf - but 
> > then after the boot do echo 1 > /proc/sys/net/ipv6/conf/all/forward (to 
> > actually get it running)
> > 
> > we'll crash and burn when taking down the interface.
> > 
> > Only setting /proc/sys/net/ipv6/conf/all/forward = 1, but never touch 
> > default, it goes down cleanly.
> > 
> > I have the ipv6/conf/default/forwarding set in sysctl.conf on all the 
> > routers, and it seems zebra sets the ipv6/conf/all/forwarding later on.
> > 
> 
> Possibly important note:
> 
> if I set up both conf.all and conf.default (order does not matter) 
> before the tunnel devices are created, everything works as expected.
> 
> eg. in sysctl.conf:
> net.ipv6.conf.default.forwarding=1
> net.ipv6.conf.all.forwarding=1
> 
> if default is set first, then tunnels created, followed by setting 
> "all"; everything breaks down on ifdown.
> 
> pretty neat :)

Thank you everyone for tracking down this bug.
I will fix this bug and come up with patch tomorrow (or so).
Thanks again.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
