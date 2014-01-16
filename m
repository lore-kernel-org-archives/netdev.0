From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Thu, 16 Jan 2014 08:29:14 -0800
Message-ID: <1389889754.31367.406.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
	 <1386603119.30495.331.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52A6BAC6.4090407@samsung.com>
	 <1386685557.30495.344.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52D7F8EF.1050407@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:56157 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbaAPQ3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 11:29:19 -0500
In-Reply-To: <52D7F8EF.1050407@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 16:21 +0100, Andrzej Pietrasiewicz wrote:
> W dniu 10.12.2013 15:25, Eric Dumazet pisze:
> > On Tue, 2013-12-10 at 07:55 +0100, Andrzej Pietrasiewicz wrote:
> >> W dniu 09.12.2013 16:31, Eric Dumazet pisze:
> >>> On Mon, 2013-12-09 at 12:47 +0100, Andrzej Pietrasiewicz wrote:
> >>>> NOT FOR COMMITTING TO MAINLINE.
> >>>>
> >>>> With g_ether loaded the sk occasionally becomes 0xffffffff.
> >>>> It happens usually after transferring few hundreds of kilobytes to few
> >>>> tens of megabytes. If sk is 0xffffffff then dereferencing it causes
> >>>> kernel panic.
> >>>>
> >>>> This is a *workaround*. I don't know enough net code to understand the core
> >>>> of the problem. However, with this patch applied the problems are gone,
> >>>> or at least pushed farther away.
> >>>
> >>> Is it happening on SMP or UP ?
> >>
> >> UP build, S5PC110
> >
> > OK
> >
> > I believe you need additional debugging to track the exact moment
> > 0xffffffff is fed to 'sk'
> >
> > It looks like a very strange bug, involving a problem in some assembly
> > helper, register save/restore, compiler bug or stack corruption or
> > something.
> >
> 
> I started with adding WARN_ON(sk == 0xffffffff); just before return in
> __inet_lookup_established(), and the problem was gone. So this looks
> very strange, like a toolchain problem.

Or a timing issue. Adding a WARN_ON() adds extra instructions and might
really change the assembly output.

> 
> I used gcc-linaro-arm-linux-gnueabihf-4.8-2013.05.
> 
> If I change the toolchain to
> 
> gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415
> 
> the problem seems to have gone away.

Its totally possible some barrier was not properly handled by the
compiler. You could disassemble the function on both toolchains and
try to spot the issue.
