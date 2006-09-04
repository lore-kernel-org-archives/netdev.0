From: Horms <horms@verge.net.au>
Subject: Re: [patch 3/4] Make sure ip_vs_ftp ports are valid
Date: Mon, 4 Sep 2006 11:02:54 +0900
Message-ID: <20060904020253.GA8761@verge.net.au>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org> <20060901101756.637601000@tabatha.lab.ultramonkey.org> <44FB60C7.30300@trash.net> <20060904004401.GD30287@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36559 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751301AbWIDCLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2006 22:11:50 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20060904004401.GD30287@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2006 at 09:44:02AM +0900, Horms wrote:
> On Mon, Sep 04, 2006 at 01:09:59AM +0200, Patrick McHardy wrote:
> > Horms wrote:
> > > I'm not entirely sure what happens in the case of a valid port,
> > > at best it'll be silently ignored. This patch ignores them a little
> > > more verbosely.
> > > 
> > > Signed-Off-By: Simon Horman <horms@verge.net.au>
> > > Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
> > > ===================================================================
> > > --- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:06:42.000000000 +0900
> > > +++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:08:19.000000000 +0900
> > > @@ -373,6 +373,12 @@
> > >  	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
> > >  		if (!ports[i])
> > >  			continue;
> > > +		if (ports[i] < 0 || ports[i] > 0xffff) {
> > > +			IP_VS_WARNING("ip_vs_ftp: Ignoring invalid "
> > > +				      "configuration port[%d] = %d\n",
> > > +				      i, ports[i]);
> > > +			continue;
> > > +		}
> > 
> > How about just changing the module parameter type to ushort, similar to
> > what ip_conntrack_ftp does?
> 
> Sure. I wasn't sure if that was possible or not.
> But as it is, I will make it so.

Here is the revised patch.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IPVS] Make sure ip_vs_ftp ports are valid

I'm not entirely sure what happens in the case of a valid port,
at best it'll be silently ignored. This patch ensures that
the port values are unsigned short values, and thus always valid.

Cc: Patrick McHardy <kaber@trash.net>
Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-04 10:47:09.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-04 10:59:30.000000000 +0900
@@ -44,8 +44,8 @@
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
  * First port is set to the default port.
  */
-static int ports[IP_VS_APP_MAX_PORTS] = {21, 0};
-module_param_array(ports, int, NULL, 0);
+static unsigned short ports[IP_VS_APP_MAX_PORTS] = {21, 0};
+module_param_array(ports, ushort, NULL, 0);
 MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
 
 /*

-- 
VGER BF report: U 0.832414
