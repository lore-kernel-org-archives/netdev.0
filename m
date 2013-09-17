From: Willy Tarreau <w@1wt.eu>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Tue, 17 Sep 2013 08:01:11 +0200
Message-ID: <20130917060111.GB9325@1wt.eu>
References: <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu> <20130916175152.4e013457@skate> <CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com> <20130916163937.GC3188@1wt.eu> <20130916164412.GD3188@1wt.eu> <CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com> <20130916174708.GG3188@1wt.eu> <20130916182807.GO12758@n2100.arm.linux.org.uk> <CACzLR4suLD90p=sEhB-qg1u35t66zKfrGQref1jX42fEfu3D8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:39620 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab3IQGBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 02:01:46 -0400
Content-Disposition: inline
In-Reply-To: <CACzLR4suLD90p=sEhB-qg1u35t66zKfrGQref1jX42fEfu3D8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ethan,

On Mon, Sep 16, 2013 at 08:43:19PM -0700, Ethan Tuttle wrote:
> I just built 3.11.1 with the posted config and got the usual crash in
> about 2 minutes with a ping flood.
> 
> The kernel image is available here:
> 
> https://www.dropbox.com/s/cqkqop3jjb1stk3/uImage-dtb.armada-370-mirabox

OK thank you. Unfortunately I can't boot it here as my only rootfs is
a squashfs and it is not enabled in this kernel.

> The md5 is 05f350a193c6c60d9dac40bea810bbdd.  You may notice the
> version string reveals a patch on top of 3.11.1, this is just a
> makefile patch to "Build a uImage with dtb already appended".

Interesting one, I was not aware of it, I'll probably add it to my
trees to stop relying on build scripts.

> Tcpdump captured about 2,800 icmp packets per second while the ping
> flood was running.

OK I've been running mine at this exact rate as well (2803 pps) for
11 minutes now. I disabled icmp_ratelimit to ensure that I got as
many responses as requests. No problem so far.

> Hope this helps!  If Willy wants to share a kernel image I'll see if I
> can crash it :)

I've put my working images here :

    http://1wt.eu/ethan-kernel/

One is done with my config, the other one with your config in which
I added support for squashfs and blk_dev_ram that I'm using to boot
a rootfs loaded in memory by the boot loader.

I can't make it fail either. I'm really starting to suspect a hardware
issue...

Next step should be that you test both kernels to be sure.

Cheers,
Willy
