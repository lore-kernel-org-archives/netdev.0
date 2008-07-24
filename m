From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined
	reference to `ei_close'
Date: Thu, 24 Jul 2008 11:29:20 +0200
Message-ID: <20080724092920.GC31358@elte.hu>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp> <20080721191519.GA15843@elte.hu> <20080721214258.787a67ca@lxorguk.ukuu.org.uk> <20080722072334.GA25241@elte.hu> <48865899.3030209@garzik.org> <20080723104520.GA20672@elte.hu> <20080724052603.GA8744@elte.hu> <20080724100615.764bac36@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:58121 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbYGXJaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 05:30:01 -0400
Content-Disposition: inline
In-Reply-To: <20080724100615.764bac36@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Thu, 24 Jul 2008 07:26:03 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > 
> > not sure it's known but despite all the fixes i still get:
> 
> I'll have a look at this next week or possibly the week after. The 
> original patches worked but they spent 3 months going round in circles 
> and I've completely given up even trying to work out what happened or 
> why all the previous updates I sent were ignored.

ok - meanwhile i'm using the workaround hack below.

	Ingo

--------------------->
commit 91de2dc9031b92157f067d78aaf2c8e58a965c0d
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Jul 21 21:18:29 2008 +0200

    hp-plus.c: work around build failure
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa533c2..1c809e4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1129,6 +1129,8 @@ config EEXPRESS_PRO
 config HPLAN_PLUS
 	tristate "HP PCLAN+ (27247B and 27252A) support"
 	depends on NET_ISA
+	# broken build with config-Mon_Jul_21_20_21_08_CEST_2008.bad
+	depends on 0
 	select CRC32
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
