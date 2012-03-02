From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] qla3xxx: ethernet: Fix bogus interrupt state flag.
Date: Fri, 02 Mar 2012 16:13:32 -0500 (EST)
Message-ID: <20120302.161332.2236794166581618113.davem@davemloft.net>
References: <1330700945-18195-1-git-send-email-santoshprasadnayak@gmail.com>
	<1330702146.2611.1.camel@bwh-desktop>
	<CAOD=uF5ebyA-yd8T8nXd9vYRw1yvFKVQd9TmcBwMnxFs6enKvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOD=uF5ebyA-yd8T8nXd9vYRw1yvFKVQd9TmcBwMnxFs6enKvA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Date: Fri, 2 Mar 2012 21:24:29 +0530

> In "ql_adapter_initialize", first unlock is done by
> "spin_unlock_irqrestore(&qdev->hw_lock, hw_flags)"
> with "hw_flags = 0"   ("hw_flags" is local variable and initialized to
> zero.),   which is as good as
> spin_unlock_irq.

You must never pass to irqrestore anything other than a hw_flags
value given by irqsave or similar.

You may not assume anything about what values hw_flags takes on nor
what those values might mean, they are architecture specific so
you may not just set it to zero and assume that does anything in
particular.
