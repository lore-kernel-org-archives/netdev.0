From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH 2/2] ucc_geth: Rework the TX logic.
Date: Thu, 26 Mar 2009 19:20:49 +0100
Message-ID: <OFEB54C9DC.647D70E1-ONC1257585.0064475A-C1257585.0064C85F@transmode.se>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se> <1238072077-27044-2-git-send-email-Joakim.Tjernlund@transmode.se> <20090326133918.GA27085@oksana.dev.rtsoft.ru> <OF5FC70952.28684E98-ONC1257585.005ADBF9-C1257585.005BDD35@transmode.se> <20090326180543.GA2406@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: leoli@freescale.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:47063 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140AbZCZSUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 14:20:52 -0400
In-Reply-To: <20090326180543.GA2406@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov <avorontsov@ru.mvista.com> wrote on 26/03/2009 19:05:43:

> On Thu, Mar 26, 2009 at 05:43:25PM +0100, Joakim Tjernlund wrote:
> [...]
> > > bd == ugeth->confBd[txQ]
> > > and
> > > !in_be32((u32 __iomem *)(bd+4))
> > > 
> > > Are not equivalent wrt. speed. MMIO accessors should be rather
> > > slow comparing to normal memory.
> > 
> > Yes, I know. I did it this way because I something broke under stress
> > when ugeth->confBd[txQ] instead. The ucc_geth_tx() and 
> > ucc_geth_start_xmit()
> > gets out of sync somehow.
> 
> Would be great if you could investigate it more. Maybe there is
> a serious bug somewhere, or maybe you're introducing another
> (yet hidden) bug...

I have spent some time on it and didn't see how to do it. I don't think
the current method hides any bugs. I have used this method on 8xx for
many years and it works well.

Actually the current method might work without the 
spin_lock_irq(&ugeth->lock)/spin_unlock_irq(&ugeth->lock)
in ucc_geth_start_xmit(). I can't break it, can you?

 Jocke
