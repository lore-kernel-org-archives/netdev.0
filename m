From: CaT <cat@zip.com.au>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Fri, 13 Apr 2007 08:52:49 +1000
Message-ID: <20070412225249.GU8345@zip.com.au>
References: <20070402014319.GA8345@zip.com.au> <20070402001300.3b66007d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nessie.weebeastie.net ([220.233.7.36]:4998 "EHLO
	bunyip.lochness.weebeastie.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753894AbXDLWvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 18:51:16 -0400
Content-Disposition: inline
In-Reply-To: <20070402001300.3b66007d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2007 at 12:13:00AM -0700, Andrew Morton wrote:
> On Mon, 2 Apr 2007 11:43:19 +1000 CaT <cat@zip.com.au> wrote:
> 
> > I take minute by minute snapshots of network traffic by sampling
> > /proc/net/dev and most of the time everything works fine. Occasionally
> > though I get petabyte byte traffic and corresponding packet traffic.
> 
> How frequently?
> 
> Are you able to provide some actual numbers (expected and actual values),
> so we can look at the bit patterns?

I have some now. These are raw lines from /proc/net/dev. In this case it's
eth0 at 22:14 that chucked a wee wibbly.

Apr 11 22:13:02 '  eth0:17227166357 81379716    0    0    0     0          0         0 33090495625 86656584    0    0    0     0       0          0 '
Apr 11 22:13:02 '  eth1:30708022097 91219466    0    0    0     0          0         0 122989582024 125073786    0    0    0     0       0          0 '
Apr 11 22:14:02 '  eth0:220898233988841368 66750274    0    0    0     0          0  86458738 52386430545 101089219 199313    0    0     0  199313          0 '
Apr 11 22:14:02 '  eth1:30708307787 91220183    0    0    0     0          0         0 122989665004 125074344    0    0    0     0       0          0 '
Apr 11 22:15:02 '  eth0:17227454818 81381144    0    0    0     0          0         0 33091307388 86658381    0    0    0     0       0          0 '
Apr 11 22:15:02 '  eth1:30708569308 91220742    0    0    0     0          0         0 122989732601 125074712    0    0    0     0       0          0 '

On another server (same hardware except for 2ru case, more ram and more hds):

Apr  9 06:18:05 '  eth0:1556640056941 3598105481    0    0    0     0          0         0 2281147324747 3318270401    0    0    0     0       0          0 '
Apr  9 06:18:05 '  eth1:912389249044 1190286687    0    0    0     0          0         0 642943095469 991257887    0    0    0     0       0          0 '
Apr  9 06:19:04 '  eth0:14250798570591813804 2284720007938 18638    0    0 18638          0  27375938 1556640980159 3345714490    0    0    0     0       0          0 '
Apr  9 06:19:04 '  eth1:912389281939 1190287072    0    0    0     0          0         0 642943219035 991258183    0    0    0     0       0          0 '
Apr  9 06:20:05 '  eth0:1556643514710 3598121584    0    0    0     0          0         0 2281154391794 3318284878    0    0    0     0       0          0 '
Apr  9 06:20:05 '  eth1:912389305767 1190287354    0    0    0     0          0         0 642943273879 991258351    0    0    0     0       0          0 '

> > This happens on an AMD64, dual core smp box with Broadcom NetXtreme II
> > nics.
> 
> What driver drivers that?  b44.c?

To clarify it's an Intel Dual Core Xeon (I just wound up as thinking of
them all as amd64s). Network card driver in use is the one defined by
CONFIG_BNX2. Kernel's monolithic.

> We do perform racy 64-bit updates of some of the stats counters.  But
> that'll only affect 32-bit kernels and I'm assuming you're running a 64-bit
> kernel on that AMD64 box (are you?)

Yes. With 32bit compat for executables built in.

-- 
    "To the extent that we overreact, we proffer the terrorists the
    greatest tribute."
    	- High Court Judge Michael Kirby
