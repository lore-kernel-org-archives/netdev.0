From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few
 KB/s
Date: Mon, 18 Nov 2013 11:26:01 +0100
Message-ID: <20131118112601.65feb708@skate>
References: <8761s0cqhh.fsf@natisbad.org>
	<slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	<87y54u59zq.fsf@natisbad.org>
	<20131112083633.GB10318@1wt.eu>
	<87a9hagex1.fsf@natisbad.org>
	<20131112100126.GB23981@1wt.eu>
	<87vbzxd473.fsf@natisbad.org>
	<20131113072257.GB10591@1wt.eu>
	<20131117141940.GA18569@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	simon.guinot@sequanux.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:40145 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750836Ab3KRK0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 05:26:05 -0500
In-Reply-To: <20131117141940.GA18569@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy, All,

On Sun, 17 Nov 2013 15:19:40 +0100, Willy Tarreau wrote:

> On Wed, Nov 13, 2013 at 08:22:57AM +0100, Willy Tarreau wrote:
> > On Tue, Nov 12, 2013 at 04:34:24PM +0100, Arnaud Ebalard wrote:
> > > Can you give a pre-3.11.7 kernel a try if you find the time? I
> > > started working on RN102 during 3.10-rc cycle but do not remember
> > > if I did the first preformance tests on 3.10 or 3.11. And if you
> > > find more time, 3.11.7 would be nice too ;-)
> > 
> > Still have not found time for this but I observed something
> > intriguing which might possibly match your experience : if I use
> > large enough send buffers on the mirabox and receive buffers on the
> > client, then the traffic drops for objects larger than 1 MB. I have
> > quickly checked what's happening and it's just that there are
> > pauses of up to 8 ms between some packets when the TCP send window
> > grows larger than about 200 kB. And since there are no drops, there
> > is no reason for the window to shrink. I suspect it's exactly
> > related to the issue explained by Eric about the timer used to
> > recycle the Tx descriptors. However last time I checked, these ones
> > were also processed in the Rx path, which means that the ACKs that
> > flow back should have had the same effect as a Tx IRQ (unless I'd
> > use asymmetric routing, which was not the case). So there might be
> > another issue. Ah, and it only happens with GSO.

I haven't read the entire discussion yet, but do you guys have
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/clk/mvebu?id=1022c75f5abd3a3b25e679bc8793d21bedd009b4
applied? It got merged recently, and it fixes a number of networking
problems on Armada 370.

I've added Simon Guinot in Cc, who is the author of this patch.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
