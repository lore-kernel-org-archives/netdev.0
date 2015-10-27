From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: fix problems from the RTNH_F_LINKDOWN
 introduction
Date: Mon, 26 Oct 2015 21:58:20 -0400
Message-ID: <20151027015819.GF3567@gospo.home.greyhouse.net>
References: <1445710800-8320-1-git-send-email-ja@ssi.bg>
 <20151026203104.GE3567@gospo.home.greyhouse.net>
 <alpine.LFD.2.11.1510262311390.1884@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:32805 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbbJ0B6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 21:58:23 -0400
Received: by qgeo38 with SMTP id o38so136446055qge.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 18:58:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1510262311390.1884@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015 at 11:15:57PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 26 Oct 2015, Andy Gospodarek wrote:
> 
> > On Sat, Oct 24, 2015 at 09:20:00PM +0300, Julian Anastasov wrote:
> > > When fib_netdev_event calls fib_disable_ip on NETDEV_DOWN event
> > > we should not delete the local routes if the local address
> > > is still present. The confusion comes from the fact that both
> > > fib_netdev_event and fib_inetaddr_event use the NETDEV_DOWN
> > > constant. Fix it by returning back the variable 'force'.
> > > 
> > > Steps to reproduce:
> > > modprobe dummy
> > > ifconfig dummy0 192.168.168.1 up
> > > ip route list table local | grep dummy | grep host
> > > local 192.168.168.1 dev dummy0  proto kernel  scope host  src 192.168.168.1
> > I tested this before and after your patch and I don't see a different
> > output.  Was I supposed to see something different?
> 
> 	Sorry, the test is missing one command. I'll
> split the patch and will add the missing ifconfig dummy0 down
> command. It was lost because I had problems adding '#' before
> the commands, which is comment, anyways.
> 
> > > Second fix
> > I would prefer you move these two fixes into 2 separate patches as it
> > isn't totally clear which hunks fix each of these issues.
> 
> 	Preparing patchset...
> 
> > Are you seeing this with iproute2 (or other tools) or are you just
> > seeing this by monitoring netlink messages/looking at a netlink cache
> > you have built inside an application?
> 
> 	ifconfig and ip route.
> 
> > I have seen a problem similar to what you have reported with netlink
> > caches and have a fix I can give you if you would like to try it.  It is
> > a slightly larger structural change, but it appears to cover covers a
> > few more cases than this fix does.
> 
> 	No, I'm focusing just on this problem.
> 
> Regards
> 

Thanks for the update.  I'll test an report back in the v2 thread.
