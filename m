From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 13 May 2014 18:22:29 +0200
Message-ID: <537246C5.9050305@weinigel.se>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>	<20140505.231229.136734008603421707.davem@davemloft.net>	<20140506032114.GP2382@two.firstfloor.org>	<20140505.232327.578134514220748085.davem@davemloft.net>	<20140506155703.GA20391@cloud>	<1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>	<20140506183216.GM19657@tassilo.jf.intel.com>	<1399407478.15399.81.camel@edumazet-glaptop2.roam.corp.google.com> <20140507143547.638c6fc2@alan.etchedpixels.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>, josh@joshtriplett.org,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140507143547.638c6fc2@alan.etchedpixels.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-05-07 15:35, One Thousand Gnomes wrote:
> IoT devices don't care. Most embedded devices don't care. A lot of the
> current generation of proprietary non Linux very low end RTOS systems
> support *one socket*, some even use a wireless controller which has a
> proprietary mini tcp/ip and wifi stack that provices *one socket*
>
> If you want Linux to run on the kind of low end 'single chip' systems or
> FPGA systems then you want to be able to run in very little memory.
> Network performance is usually near irrelevant. If its controlling a
> smart plug it doesn't need to do megabit encrypted streams or fast
> connect.
>
This describes an industrial control system I've been working on for the
last ten years or so.  It runs one application, this application makes
one single TCP connection to a server which then stays up forever.  The
server can send modified configuration to the application and the
application sends periodic reports about what it is doing.  We've
replaced 9600 bps current loop with TCP, not for performance reasons but
for convenience.  We have no use for ethtool, no use for packet filters,
no use for firewalling and don't care if a socket uses 100 bytes or
10kBytes of kernel memory since we only have one.  There are probably
lots of embedded systems that need those features, but there are also
lots of systems that don't.

The first version of the hardware used a 2.4.26 kernel on an Axis ETRAX
LX processor, now were using a 2.6.33 kernel on an Atmel ARM9
processor.  We have a problem with the flash getting corrupted every now
and then, and this seems to be fixed in the latest stable kernel
(3.10).   There are about 2000 changes to drivers/mtd and so far we have
not been able to bisect this to find out where and why things started
working.

So we'd like to upgrade but we are also starting to run short on flash
and the 3.10 kernel is noticeably bigger with the same configuration. 
Switching from gzip to xz compression did give us back enough flash
space to fit everything in, but it's still tight.  So if we can save a
couple of 100k of text size and get a slightly less performant or
featureful TCP stack, that would be a very good tradeoff for us.

  /Christer
