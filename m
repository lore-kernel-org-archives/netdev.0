From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Kernel panic with the b44 driver in 2.6.35-rc1
Date: Tue, 1 Jun 2010 09:33:19 -0400
Message-ID: <20100601133318.GA26701@tuxdriver.com>
References: <4C0414F3.8030409@tvcablenet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "news.gmane.org" <francois.valenduc@tvcablenet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57144 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755885Ab0FANpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 09:45:11 -0400
Content-Disposition: inline
In-Reply-To: <4C0414F3.8030409@tvcablenet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 31, 2010 at 09:58:43PM +0200, news.gmane.org wrote:

> I have a kernel panic at startup with the b44 driver with the 2.6.35-rc1
> kernel. I have submitted a bug report (see
> https://bugzilla.kernel.org/show_bug.cgi?id=16074) but until know, I
> din't get any answer yet. Does anybody knows what's happening. I have
> tried several git-bisect run but I didn't find any conclusive result.
> The first bad-commit was different each time and if I revert it, the
> problem still occurs anyway.

This patch is already on its way to Linus -- it should fix the problem
you are seeing:

commit da1fdb02d9200ff28b6f3a380d21930335fe5429
Author: Christoph Fritz <chf.fritz@googlemail.com>
Date:   Fri May 28 10:45:59 2010 +0200

    ssb: fix NULL ptr deref when pcihost_wrapper is used
    
    Ethernet driver b44 does register ssb by it's pcihost_wrapper
    and doesn't set ssb_chipcommon. A check on this value
    introduced with commit d53cdbb94a52a920d5420ed64d986c3523a56743
    and ea2db495f92ad2cf3301623e60cb95b4062bc484 triggers:
    
    BUG: unable to handle kernel NULL pointer dereference at 00000010
    IP: [<c1266c36>] ssb_is_sprom_available+0x16/0x30
    
    Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
