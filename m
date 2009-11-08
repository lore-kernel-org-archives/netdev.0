From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Sun, 08 Nov 2009 01:08:48 -0800 (PST)
Message-ID: <20091108.010848.116517157.davem@davemloft.net>
References: <E1N63WM-0003xK-PN@jdl.com> <E1N64UY-00049g-Hb@jdl.com>
	<20091105165738.GA31923@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jdl@jdl.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	afleming@freescale.com, jason.wessel@windriver.com,
	shemminger@vyatta.com, buytenh@wantstofly.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091105165738.GA31923@oksana.dev.rtsoft.ru>
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
Date: Thu, 5 Nov 2009 19:57:38 +0300

> But that basically means that with skb recycling we can't safely
> use KGDBoE, though we can add something like this:

Please stop adding special logic only to your driver to handle these
things.

Either it's a non-issue, or it's going to potentially be an issue for
everyone using skb_recycle_check() in a NAPI driver, right?

So why not add the "in_interrupt()" or whatever check to
skb_recycle_check() and if the context is unsuitable return false (0)
ok?
