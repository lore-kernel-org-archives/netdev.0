From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: Fix false xmit recursion detect with two ppp
 devices
Date: Tue, 18 Jul 2017 11:21:45 -0700 (PDT)
Message-ID: <20170718.112145.599694527854940189.davem@davemloft.net>
References: <1500287682-18872-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, g.nault@alphalink.fr, linux-ppp@vger.kernel.org,
        netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1500287682-18872-1-git-send-email-gfree.wind@vip.163.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: gfree.wind@vip.163.com
Date: Mon, 17 Jul 2017 18:34:42 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The global percpu variable ppp_xmit_recursion is used to detect the ppp
> xmit recursion to avoid the deadlock, which is caused by one CPU tries to
> lock the xmit lock twice. But it would report false recursion when one CPU
> wants to send the skb from two different PPP devices, like one L2TP on the
> PPPoE. It is a normal case actually.
> 
> Now use one percpu member of struct ppp instead of the gloable variable to
> detect the xmit recursion of one ppp device.
> 
> Fixes: 55454a565836 ("ppp: avoid dealock on recursive xmit")
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> Signed-off-by: Liu Jianying <jianying.liu@ikuai8.com>

Indeed, for a per-ppp lock recursion check we need a per-ppp counter.

Applied, thanks!
