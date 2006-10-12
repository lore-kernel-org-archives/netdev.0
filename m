From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] bridge: flush forwarding table when device carrier off
Date: Thu, 12 Oct 2006 17:30:33 -0400
Message-ID: <1160688633.5047.5.camel@jzny2>
References: <20061012112431.0550b252@dxpl.pdx.osdl.net>
	 <20061012201043.GA29253@gospo.rdu.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19681 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751056AbWJLVag
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 17:30:36 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GY88W-0006M5-2e
	for netdev@vger.kernel.org; Thu, 12 Oct 2006 17:30:40 -0400
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20061012201043.GA29253@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-10 at 16:10 -0400, Andy Gospodarek wrote:
> On Thu, Oct 12, 2006 at 11:24:31AM -0700, Stephen Hemminger wrote:
> > Flush the forwarding table when carrier is lost. This helps for
> > availability because we don't want to forward to a downed device and
> > new packets may come in on other links.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > 
> 
> Stephen,
> 
> This is an excellent idea 

I am on the other extreme - this is problematic if you have a large
table already learnt. Agrevate that with an unstable link and it gets a
lot worse. Both of which dont sound unrealistic in say a wireless AP.

A more sane policy i have seen is a timer that flushes the table after a
programmed period; this way you counter a flipflop-ing link.
IOW, the best place is to have this in some user space daemon. If it has
to be in the kernel, can you add a systcl to disable it?

cheers,
jamal



