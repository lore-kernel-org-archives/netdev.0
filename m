From: Ingo Molnar <mingo@elte.hu>
Subject: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference to
	`ei_close'
Date: Mon, 21 Jul 2008 21:15:19 +0200
Message-ID: <20080721191519.GA15843@elte.hu>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56403 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755556AbYGUTPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:15:39 -0400
Content-Disposition: inline
In-Reply-To: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:

> Since commit 055e5110ae0c0c1176a75b78d789294f2ff2f7af ("8390: Split
> 8390 support into a pausing and a non pausing driver core"), ne.c
> cause this build failure:
> 
> drivers/built-in.o: In function `ne_probe1':
> ne.c:(.init.text+0x2464): undefined reference to `NS8390_init'
> drivers/built-in.o: In function `ne_block_output':
> ne.c:(.text.ne_block_output+0x1b0): undefined reference to `NS8390_init'

i just triggered a similar build failure, but in a different 
ne2000-derived file:

 drivers/built-in.o: In function `hpp_close':
 hp-plus.c:(.text+0xd7c1a): undefined reference to `ei_close'
 drivers/built-in.o: In function `hpp_open':
 hp-plus.c:(.text+0xd7c3c): undefined reference to `ei_interrupt'
 hp-plus.c:(.text+0xd7ca9): undefined reference to `ei_open'
 drivers/built-in.o: In function `hpp_probe1':
 hp-plus.c:(.init.text+0xab54): undefined reference to `ei_poll'
 hp-plus.c:(.init.text+0xabed): undefined reference to `NS8390_init'
 drivers/built-in.o: In function `hp_plus_probe':
 (.init.text+0xac4c): undefined reference to `__alloc_ei_netdev'
 make: *** [.tmp_vmlinux1] Error 1

with this config:

  http://redhat.com/~mingo/misc/config-Mon_Jul_21_20_21_08_CEST_2008.bad

	Ingo
