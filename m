From: "Will Deacon" <will.deacon@arm.com>
Subject: RE: [PATCH RFC 0/4] ARM/KGDB: Some fixes for SMP machines
Date: Thu, 8 Jul 2010 09:48:56 +0100
Message-ID: <27118.9785366461$1278579013@news.gmane.org>
References: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Jason Wessel <jason.wessel@windriver.com>
To: "'Anton Vorontsov'" <cbouatmailru@gmail.com>,
	<kgdb-bugreport@lists.sourceforge.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Content-Language: en-gb
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Anton,

> It appears that KGDB can easily hang SMP ARM machines.

Yep. As pointed out at:

http://lkml.org/lkml/2010/4/8/214

Commit ae6bf53e broke kgdb on SMP systems because it incorrectly assumes
that atomic_{inc,dec} imply barriers. Until this is fixed, it will never
work reliably on ARM. Try reverting the patch [this doesn't completely
resolve the situation, but it might help].

> 1. I'm testing with I/D caches disabled. With enabled caches,
>    ARMv6K still locks-up. I'll test ARMv7 soon, and will try
>    to debug cache issues on ARMv6K.

This patch might help if you're using the ARM11MPCore:

http://lists.infradead.org/pipermail/linux-arm-kernel/2010-May/016567.html

Hope that helps,

Will
