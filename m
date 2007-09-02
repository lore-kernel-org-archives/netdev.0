From: Satyam Sharma <satyam@infradead.org>
Subject: Re: 2.6.23-rc4-mm1: unpingable box and NULL dereference at
 tcp_rto_min()
Date: Sun, 2 Sep 2007 10:32:06 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709021016470.20781@enigma.security.iitk.ac.in>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
 <20070902023618.GA2537@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54849 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbXIBEtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 00:49:00 -0400
In-Reply-To: <20070902023618.GA2537@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 2 Sep 2007, Alexey Dobriyan wrote:
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000039 RIP: 
>  [<ffffffff803b6f7c>] tcp_rto_min+0xc/0x20

tcp_rto_min() lacks a check-for-NULL. You want 5c127c58ae9bf196 from
the net-2.6.git tree -- so this will be gone in -rc6.

> P.S.: uh-oh, it's "[TCP] Allow minnimum RTO ..." aka 05bb1fad1cde

Yup, it came from this last commit in net-2.6 before -rc5.

[ Considering it's pretty core code (and thus the oops fairly easily
  reproducible), I initially thought this must've come from net-2.6.24.
  I suspect lot of testers might hit this, so would be wise to put that
  patch up as a hot-fix ? ]


Satyam
