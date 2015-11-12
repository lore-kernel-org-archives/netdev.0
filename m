From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: kasan r8169 use-after-free trace.
Date: Thu, 12 Nov 2015 11:24:59 -0500
Message-ID: <20151112162459.GA20797@codemonkey.org.uk>
References: <20151111033028.GA25018@codemonkey.org.uk>
 <20151111091928.GA14531@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:39629 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbbKLQZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 11:25:09 -0500
Content-Disposition: inline
In-Reply-To: <20151111091928.GA14531@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 10:19:28AM +0100, Francois Romieu wrote:
 > Dave Jones <davej@codemonkey.org.uk> :
 > > This happens during boot, (and then there's a flood of traces that happen so fast
 > > afterwards it completely overwhelms serial console; not sure if they're the
 > > same/related or not).
 > > 
 > > ==================================================================
 > > BUG: KASAN: use-after-free in rtl8169_poll+0x4b6/0xb70 at addr ffff8801d43b3288
 > > Read of size 1 by task kworker/0:3/188
 > > =============================================================================
 > > BUG kmalloc-256 (Not tainted): kasan: bad access detected
 > > -----------------------------------------------------------------------------
 > > 
 > > Disabling lock debugging due to kernel taint
 > > INFO: Slab 0xffffea000750ecc0 objects=16 used=16 fp=0x          (null) flags=0x8000000000000080
 > > INFO: Object 0xffff8801d43b3200 @offset=512 fp=0xffff8801d43b3800
 > > 
 > > Bytes b4 ffff8801d43b31f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
 > > Object ffff8801d43b3200: 00 38 3b d4 01 88 ff ff 00 00 00 00 00 00 00 00  .8;.............
 > 
 > Does the patch below cure it ?

It did, thanks for the quick turnaround!  It also turns out this was responsible
for the flood of spew afterwards. It's completely silent when I apply your diff.

	Dave
