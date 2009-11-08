From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] gianfar: Make polling safe with IRQs disabled
Date: Sun, 08 Nov 2009 01:05:33 -0800 (PST)
Message-ID: <20091108.010533.212571001.davem@davemloft.net>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, afleming@freescale.com,
	jason.wessel@windriver.com
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 5 Nov 2009 01:57:11 +0300

> When using KGDBoE, gianfar driver spits 'Interrupt problem' messages,
> which appears to be a legitimate warning, i.e. we may end up calling
> netif_receive_skb() or vlan_hwaccel_receive_skb() with IRQs disabled.
> 
> This patch reworks the RX path so that if netpoll is enabled (the
> only case when the driver don't know from what context the polling
> may be called), we check whether IRQs are disabled, and if so we
> fall back to safe variants of skb receiving functions.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

This is bogus, I'll tell you why.

When you go into netif_receive_skb() we have a special check,
"if (netpoll_receive_skb(..." that takes care of all of the
details concerning doing a ->poll() from IRQ disabled context
via netpoll.

So this code you're adding should not be necessary.

Or, explain to me why no other driver needs special logic in their
->poll() handler like this and does not run into any kinds of netpoll
problems :-)
